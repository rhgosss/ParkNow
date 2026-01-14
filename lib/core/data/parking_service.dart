// lib/core/data/parking_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingService {
  static final ParkingService _instance = ParkingService._internal();
  factory ParkingService() => _instance;
  ParkingService._internal() {
    _generateDemoSpots();
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Local demo spots (in-memory)
  final List<GarageSpot> _demoSpots = [];
  
  // Cache for Firestore spots
  List<GarageSpot> _firestoreSpots = [];
  DateTime? _lastFetch;

  // Bookings  
  final List<Booking> _bookings = [];

  List<GarageSpot> get allSpots => [..._demoSpots, ..._firestoreSpots];
  List<Booking> get bookings => List.unmodifiable(_bookings);

  // Fetch spots from Firestore (call this to refresh)
  Future<void> fetchSpotsFromFirestore() async {
    try {
      final snapshot = await _db.collection('spots').get();
      _firestoreSpots = snapshot.docs.map((doc) => GarageSpot.fromFirestore(doc.id, doc.data())).toList();
      _lastFetch = DateTime.now();
    } catch (e) {
      // Keep existing data on error
    }
  }

  // Get single spot
  GarageSpot? getSpot(String id) {
    try {
      return allSpots.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // Get spot (async with fresh Firestore data)
  Future<GarageSpot?> getSpotAsync(String id) async {
    // Check local first
    final local = getSpot(id);
    if (local != null) return local;
    
    // Try Firestore
    final doc = await _db.collection('spots').doc(id).get();
    if (doc.exists) {
      return GarageSpot.fromFirestore(doc.id, doc.data()!);
    }
    return null;
  }

  // Search logic
  String _removeDiacritics(String str) {
    var withDia = 'ΆάΈέΉήΊίΌόΎύΏώϊϋΐΰ';
    var withoutDia = 'ΑαΕεΗηΙιΟοΥυΩωιυιυ';
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }

  List<GarageSpot> search(String query) {
    final spots = allSpots;
    if (query.isEmpty) return spots;
    final q = _removeDiacritics(query.toLowerCase());
    return spots.where((s) {
      final title = _removeDiacritics(s.title.toLowerCase());
      final subtitle = _removeDiacritics(s.subtitle.toLowerCase());
      final area = _removeDiacritics(s.area.toLowerCase());
      return title.contains(q) || subtitle.contains(q) || area.contains(q);
    }).toList();
  }

  // Search with fresh Firestore data
  Future<List<GarageSpot>> searchAsync(String query) async {
    await fetchSpotsFromFirestore();
    return search(query);
  }

  // === SPOTS MANAGEMENT ===

  // Add spot to Firestore
  Future<void> addSpot(GarageSpot spot) async {
    await _db.collection('spots').doc(spot.id).set(spot.toFirestore());
    _firestoreSpots.insert(0, spot);
  }

  // Get spots for owner (both local and Firestore)
  List<GarageSpot> getSpotsForOwner(String userId) {
    return allSpots.where((s) => s.ownerId == userId).toList();
  }

  // Get spots for owner (async with fresh data)
  Future<List<GarageSpot>> getSpotsForOwnerAsync(String userId) async {
    await fetchSpotsFromFirestore();
    return getSpotsForOwner(userId);
  }

  // === REVIEWS ===

  Future<void> addReview(String spotId, Review review) async {
    // Add to Firestore
    await _db.collection('spots').doc(spotId).collection('reviews').add(review.toFirestore());
    
    // Update spot rating
    final reviewsSnapshot = await _db.collection('spots').doc(spotId).collection('reviews').get();
    double totalRating = 0;
    for (var doc in reviewsSnapshot.docs) {
      totalRating += (doc.data()['rating'] as num).toDouble();
    }
    final newRating = totalRating / reviewsSnapshot.docs.length;
    
    await _db.collection('spots').doc(spotId).update({
      'rating': newRating,
      'reviewsCount': reviewsSnapshot.docs.length,
    });

    // Update local cache
    final spotIndex = _firestoreSpots.indexWhere((s) => s.id == spotId);
    if (spotIndex != -1) {
      final spot = _firestoreSpots[spotIndex];
      _firestoreSpots[spotIndex] = GarageSpot(
        id: spot.id,
        title: spot.title,
        subtitle: spot.subtitle,
        area: spot.area,
        pricePerHour: spot.pricePerHour,
        pricePerDay: spot.pricePerDay,
        pos: spot.pos,
        rating: newRating,
        reviewsCount: reviewsSnapshot.docs.length,
        features: spot.features,
        ownerName: spot.ownerName,
        reviews: [review, ...spot.reviews],
        ownerId: spot.ownerId,
      );
    }
  }

  // === BOOKINGS ===

  Future<void> addBooking(Booking booking) async {
    await _db.collection('bookings').doc(booking.id).set(booking.toFirestore());
    _bookings.add(booking);
  }

  List<Booking> getBookingsForUser(String userId) {
    return _bookings.where((b) => b.userId == userId).toList();
  }

  Future<List<Booking>> getBookingsForUserAsync(String userId) async {
    final snapshot = await _db.collection('bookings')
        .where('userId', isEqualTo: userId)
        .get();
    
    List<Booking> bookings = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final spot = await getSpotAsync(data['spotId']);
      if (spot != null) {
        bookings.add(Booking.fromFirestore(doc.id, data, spot));
      }
    }
    return bookings;
  }

  List<Booking> getActiveBookingsForUser(String userId) {
    final now = DateTime.now();
    return _bookings.where((b) => 
      b.userId == userId && 
      b.active && 
      b.endTime.isAfter(now)
    ).toList();
  }

  List<Booking> getBookingsForOwner(String ownerId) {
    final ownerSpotIds = allSpots
      .where((s) => s.ownerId == ownerId)
      .map((s) => s.id)
      .toSet();
    return _bookings.where((b) => ownerSpotIds.contains(b.spot.id)).toList();
  }

  // === AVAILABILITY ===

  bool isSpotAvailable(String spotId, DateTime date) {
    final requestedEnd = date.add(const Duration(hours: 2));
    
    for (var b in _bookings) {
      if (b.spot.id == spotId && b.active) {
        if (date.isBefore(b.endTime) && requestedEnd.isAfter(b.startTime)) {
          return false;
        }
      }
    }
    
    final seed = spotId.hashCode + date.day + date.hour;
    final rnd = Random(seed);
    return rnd.nextDouble() < 0.7;
  }

  // === DEMO DATA GENERATION ===
  
  void _generateDemoSpots() {
    final rnd = Random(42);
    final areas = [
      _Area('Κολωνάκι', const LatLng(37.9792, 23.7390)),
      _Area('Σύνταγμα', const LatLng(37.9755, 23.7348)),
      _Area('Πλάκα', const LatLng(37.9715, 23.7294)),
      _Area('Παγκράτι', const LatLng(37.9697, 23.7441)),
      _Area('Κυψέλη', const LatLng(38.0019, 23.7397)),
      _Area('Αμπελόκηποι', const LatLng(37.9890, 23.7592)),
      _Area('Νέος Κόσμος', const LatLng(37.9577, 23.7288)),
      _Area('Γκάζι', const LatLng(37.9786, 23.7127)),
      _Area('Μοναστηράκι', const LatLng(37.9768, 23.7259)),
      _Area('Εξάρχεια', const LatLng(37.9868, 23.7329)),
    ];

    final featuresList = ['Covered', 'Cameras', 'Guard', 'Lighting', 'EV Charging', '24/7'];
    final owners = ['Γιώργος Π.', 'ParknGo AE', 'CitySpots', 'Μαρία Κ.', 'Athens Parking'];

    int idCounter = 1;
    for (var area in areas) {
      final count = 3 + rnd.nextInt(3);
      for (var i = 0; i < count; i++) {
        final lat = area.center.latitude + (rnd.nextDouble() - 0.5) * 0.005;
        final lng = area.center.longitude + (rnd.nextDouble() - 0.5) * 0.005;
        final price = 4.0 + rnd.nextInt(8).toDouble(); 
        final daily = price * (8 + rnd.nextInt(4));

        final featCount = 3 + rnd.nextInt(3);
        final feats = (featuresList.toList()..shuffle(rnd)).take(featCount).toList();

        final reviewsCount = 5 + rnd.nextInt(150);
        final reviews = List.generate(min(5, reviewsCount), (index) => _generateReview(rnd));

        _demoSpots.add(GarageSpot(
          id: 'demo_s${idCounter++}',
          title: '${area.name} Parking ${i + 1}',
          subtitle: '${area.name}, Αθήνα',
          area: area.name,
          pricePerHour: price,
          pricePerDay: daily,
          pos: LatLng(lat, lng),
          rating: 3.0 + rnd.nextDouble() * 2.0,
          reviewsCount: reviewsCount,
          features: feats,
          ownerName: owners[rnd.nextInt(owners.length)],
          reviews: reviews,
        ));
      }
    }
  }

  Review _generateReview(Random rnd) {
    final names = ['Νίκος', 'Ελένη', 'Κώστας', 'Άννα', 'Δημήτρης'];
    final comments = [
      'Πολύ καλό πάρκινγκ!',
      'Ασφαλές και καθαρό.',
      'Λίγο ακριβό αλλά αξίζει.',
      'Εύκολη πρόσβαση.',
      'Ο υπάλληλος ήταν πολύ ευγενικός.'
    ];
    return Review(
      userName: names[rnd.nextInt(names.length)],
      rating: 3 + rnd.nextInt(3).toDouble(),
      comment: comments[rnd.nextInt(comments.length)],
      date: DateTime.now().subtract(Duration(days: rnd.nextInt(300))),
    );
  }
}

// === MODELS ===

class GarageSpot {
  final String id;
  final String title;
  final String subtitle;
  final String area;
  final double pricePerHour;
  final double pricePerDay;
  final LatLng pos;
  final double rating;
  final int reviewsCount;
  final List<String> features;
  final String ownerName;
  final List<Review> reviews;
  final String? ownerId;

  GarageSpot({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.area,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.pos,
    required this.rating,
    required this.reviewsCount,
    required this.features,
    required this.ownerName,
    required this.reviews,
    this.ownerId,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subtitle': subtitle,
      'area': area,
      'pricePerHour': pricePerHour,
      'pricePerDay': pricePerDay,
      'lat': pos.latitude,
      'lng': pos.longitude,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'features': features,
      'ownerName': ownerName,
      'ownerId': ownerId,
    };
  }

  factory GarageSpot.fromFirestore(String id, Map<String, dynamic> data) {
    return GarageSpot(
      id: id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      area: data['area'] ?? '',
      pricePerHour: (data['pricePerHour'] as num?)?.toDouble() ?? 0,
      pricePerDay: (data['pricePerDay'] as num?)?.toDouble() ?? 0,
      pos: LatLng(
        (data['lat'] as num?)?.toDouble() ?? 0,
        (data['lng'] as num?)?.toDouble() ?? 0,
      ),
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (data['reviewsCount'] as num?)?.toInt() ?? 0,
      features: List<String>.from(data['features'] ?? []),
      ownerName: data['ownerName'] ?? '',
      reviews: [], // Reviews loaded separately
      ownerId: data['ownerId'],
    );
  }
}

class Review {
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;
  
  Review({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'date': Timestamp.fromDate(date),
    };
  }
}

class _Area {
  final String name;
  final LatLng center;
  _Area(this.name, this.center);
}

class Booking {
  final String id;
  final GarageSpot spot;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final bool active;
  final String userId;
  final String pinCode;

  Booking({
    required this.id,
    required this.spot,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    this.active = true,
    required this.userId,
    required this.pinCode,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'spotId': spot.id,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'totalPrice': totalPrice,
      'active': active,
      'userId': userId,
      'pinCode': pinCode,
    };
  }

  factory Booking.fromFirestore(String id, Map<String, dynamic> data, GarageSpot spot) {
    return Booking(
      id: id,
      spot: spot,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      active: data['active'] ?? true,
      userId: data['userId'] ?? '',
      pinCode: data['pinCode'] ?? '',
    );
  }
}
