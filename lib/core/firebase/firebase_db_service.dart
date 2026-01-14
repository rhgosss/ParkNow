// lib/core/firebase/firebase_db_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirebaseDbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== SPOTS ==========
  
  CollectionReference<Map<String, dynamic>> get _spotsCollection => 
      _db.collection('spots');

  Future<List<SpotData>> getAllSpots() async {
    final snapshot = await _spotsCollection.get();
    return snapshot.docs.map((doc) => SpotData.fromMap(doc.id, doc.data())).toList();
  }

  Future<SpotData?> getSpot(String id) async {
    final doc = await _spotsCollection.doc(id).get();
    if (doc.exists) {
      return SpotData.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  Future<List<SpotData>> searchSpots(String query) async {
    if (query.isEmpty) return getAllSpots();
    
    // Firestore doesn't support LIKE queries, so we fetch all and filter client-side
    // For production, use Algolia or similar for search
    final all = await getAllSpots();
    final q = query.toLowerCase();
    return all.where((s) => 
      s.title.toLowerCase().contains(q) || 
      s.subtitle.toLowerCase().contains(q) ||
      s.area.toLowerCase().contains(q)
    ).toList();
  }

  Future<void> addSpot(SpotData spot) async {
    await _spotsCollection.doc(spot.id).set(spot.toMap());
  }

  Future<List<SpotData>> getSpotsForOwner(String ownerId) async {
    final snapshot = await _spotsCollection
        .where('ownerId', isEqualTo: ownerId)
        .get();
    return snapshot.docs.map((doc) => SpotData.fromMap(doc.id, doc.data())).toList();
  }

  // ========== REVIEWS ==========
  
  Future<void> addReview(String spotId, ReviewData review) async {
    await _spotsCollection.doc(spotId).collection('reviews').add(review.toMap());
    
    // Update spot rating
    final reviews = await _spotsCollection.doc(spotId).collection('reviews').get();
    double totalRating = 0;
    for (var doc in reviews.docs) {
      totalRating += (doc.data()['rating'] as num).toDouble();
    }
    final newRating = totalRating / reviews.docs.length;
    
    await _spotsCollection.doc(spotId).update({
      'rating': newRating,
      'reviewsCount': reviews.docs.length,
    });
  }

  Future<List<ReviewData>> getReviews(String spotId) async {
    final snapshot = await _spotsCollection.doc(spotId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => ReviewData.fromMap(doc.data())).toList();
  }

  // ========== BOOKINGS ==========
  
  CollectionReference<Map<String, dynamic>> get _bookingsCollection => 
      _db.collection('bookings');

  Future<void> addBooking(BookingData booking) async {
    await _bookingsCollection.doc(booking.id).set(booking.toMap());
  }

  Future<List<BookingData>> getBookingsForUser(String userId) async {
    final snapshot = await _bookingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .get();
    return snapshot.docs.map((doc) => BookingData.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<BookingData>> getBookingsForOwner(String ownerId) async {
    // Get owner's spots first
    final spots = await getSpotsForOwner(ownerId);
    final spotIds = spots.map((s) => s.id).toList();
    
    if (spotIds.isEmpty) return [];
    
    final snapshot = await _bookingsCollection
        .where('spotId', whereIn: spotIds)
        .get();
    return snapshot.docs.map((doc) => BookingData.fromMap(doc.id, doc.data())).toList();
  }
}

// ========== DATA MODELS ==========

class SpotData {
  final String id;
  final String title;
  final String subtitle;
  final String area;
  final double pricePerHour;
  final double pricePerDay;
  final double lat;
  final double lng;
  final double rating;
  final int reviewsCount;
  final List<String> features;
  final String ownerName;
  final String? ownerId;

  SpotData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.area,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.reviewsCount,
    required this.features,
    required this.ownerName,
    this.ownerId,
  });

  LatLng get pos => LatLng(lat, lng);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'area': area,
      'pricePerHour': pricePerHour,
      'pricePerDay': pricePerDay,
      'lat': lat,
      'lng': lng,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'features': features,
      'ownerName': ownerName,
      'ownerId': ownerId,
    };
  }

  factory SpotData.fromMap(String id, Map<String, dynamic> map) {
    return SpotData(
      id: id,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      area: map['area'] ?? '',
      pricePerHour: (map['pricePerHour'] as num?)?.toDouble() ?? 0,
      pricePerDay: (map['pricePerDay'] as num?)?.toDouble() ?? 0,
      lat: (map['lat'] as num?)?.toDouble() ?? 0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (map['reviewsCount'] as num?)?.toInt() ?? 0,
      features: List<String>.from(map['features'] ?? []),
      ownerName: map['ownerName'] ?? '',
      ownerId: map['ownerId'],
    );
  }
}

class ReviewData {
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  ReviewData({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'date': Timestamp.fromDate(date),
    };
  }

  factory ReviewData.fromMap(Map<String, dynamic> map) {
    return ReviewData(
      userName: map['userName'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      comment: map['comment'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class BookingData {
  final String id;
  final String spotId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final String pinCode;
  final bool active;

  BookingData({
    required this.id,
    required this.spotId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.pinCode,
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'spotId': spotId,
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'totalPrice': totalPrice,
      'pinCode': pinCode,
      'active': active,
    };
  }

  factory BookingData.fromMap(String id, Map<String, dynamic> map) {
    return BookingData(
      id: id,
      spotId: map['spotId'] ?? '',
      userId: map['userId'] ?? '',
      startTime: (map['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (map['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0,
      pinCode: map['pinCode'] ?? '',
      active: map['active'] ?? true,
    );
  }
}
