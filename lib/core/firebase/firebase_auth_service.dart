// lib/core/firebase/firebase_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { driver, host }

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;
  bool get isLoggedIn => currentFirebaseUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register new user
  Future<AppUserData> register(String email, String password, UserRole role, {String name = 'User'}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;
    final userData = AppUserData(
      id: user.uid,
      email: email,
      name: name,
      role: role,
      favoriteSpotIds: [],
      createdAt: DateTime.now(),
    );

    // Save user data to Firestore
    await _db.collection('users').doc(user.uid).set(userData.toMap());
    
    return userData;
  }

  // Login existing user
  Future<AppUserData?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      return await getUserData(credential.user!.uid);
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<AppUserData?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUserData.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  // Update user name
  Future<void> updateUserName(String uid, String newName) async {
    await _db.collection('users').doc(uid).update({'name': newName});
  }

  // Toggle favorite
  Future<void> toggleFavorite(String uid, String spotId) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      final favorites = List<String>.from(doc.data()?['favoriteSpotIds'] ?? []);
      if (favorites.contains(spotId)) {
        favorites.remove(spotId);
      } else {
        favorites.add(spotId);
      }
      await _db.collection('users').doc(uid).update({'favoriteSpotIds': favorites});
    }
  }

  // Switch role
  Future<void> switchRole(String uid, UserRole newRole) async {
    await _db.collection('users').doc(uid).update({
      'role': newRole == UserRole.host ? 'host' : 'driver',
    });
  }
}

class AppUserData {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final List<String> favoriteSpotIds;
  final DateTime createdAt;

  AppUserData({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.favoriteSpotIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role == UserRole.host ? 'host' : 'driver',
      'favoriteSpotIds': favoriteSpotIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppUserData.fromMap(String id, Map<String, dynamic> map) {
    return AppUserData(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? 'User',
      role: map['role'] == 'host' ? UserRole.host : UserRole.driver,
      favoriteSpotIds: List<String>.from(map['favoriteSpotIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  AppUserData copyWith({
    String? name,
    UserRole? role,
    List<String>? favoriteSpotIds,
  }) {
    return AppUserData(
      id: id,
      email: email,
      name: name ?? this.name,
      role: role ?? this.role,
      favoriteSpotIds: favoriteSpotIds ?? this.favoriteSpotIds,
      createdAt: createdAt,
    );
  }
}
