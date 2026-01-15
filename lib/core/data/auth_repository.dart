// lib/core/data/auth_repository.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'storage_service.dart';

enum UserRole { driver, host }

class AppUser {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String? photoUrl;
  UserRole role;
  final DateTime createdAt;
  
  // Host specific
  double totalIncome;
  List<String> ownedSpotIds;

  // Driver specific
  List<String> bookingIds;
  List<String> favoriteSpotIds;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone = '',
    this.photoUrl,
    this.role = UserRole.driver,
    DateTime? createdAt,
    this.totalIncome = 0.0,
    this.ownedSpotIds = const [],
    this.bookingIds = const [],
    this.favoriteSpotIds = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppUser.fromFirestore(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? 'User',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'],
      role: data['role'] == 'host' ? UserRole.host : UserRole.driver,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalIncome: (data['totalIncome'] as num?)?.toDouble() ?? 0.0,
      ownedSpotIds: List<String>.from(data['ownedSpotIds'] ?? []),
      bookingIds: List<String>.from(data['bookingIds'] ?? []),
      favoriteSpotIds: List<String>.from(data['favoriteSpotIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role == UserRole.host ? 'host' : 'driver',
      'createdAt': Timestamp.fromDate(createdAt),
      'totalIncome': totalIncome,
      'ownedSpotIds': ownedSpotIds,
      'bookingIds': bookingIds,
      'favoriteSpotIds': favoriteSpotIds,
    };
  }
}

class AuthRepository extends ChangeNotifier {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  
  // Init: Restore session
  Future<void> init() async {
    // 1. Check StorageService for saved session
    await StorageService().init();
    final savedUid = StorageService().getSession();
    
    if (savedUid != null) {
      // Try to fetch user from Firestore
      // Or if we had local mock storage for users, fetch there.
      // Since we use Firestore for users, we try that.
      try {
        final doc = await _db.collection('users').doc(savedUid).get();
        if (doc.exists) {
           _currentUser = AppUser.fromFirestore(savedUid, doc.data()!);
           notifyListeners();
        } else {
           // User ID saved but not in DB? Weird. Clear session.
           await StorageService().clearSession();
        }
      } catch (e) {
        print('Error restoring session: $e');
      }
    }
  }

  // Validate email format
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Το email είναι υποχρεωτικό';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Μη έγκυρη μορφή email';
    }
    return null;
  }

  // Validate password
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Ο κωδικός είναι υποχρεωτικός';
    }
    if (password.length < 6) {
      return 'Ο κωδικός πρέπει να έχει τουλάχιστον 6 χαρακτήρες';
    }
    return null;
  }

  // Validate name
  static String? validateName(String name) {
    if (name.trim().isEmpty) {
      return 'Το όνομα είναι υποχρεωτικό';
    }
    if (name.trim().length < 2) {
      return 'Το όνομα πρέπει να έχει τουλάχιστον 2 χαρακτήρες';
    }
    return null;
  }

  // Validate phone
  static String? validatePhone(String phone) {
    if (phone.isEmpty) {
      return 'Το τηλέφωνο είναι υποχρεωτικό';
    }
    // Remove spaces and dashes for validation
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleanPhone.length < 10) {
      return 'Μη έγκυρος αριθμός τηλεφώνου';
    }
    return null;
  }

  // Check if email exists (before registration)
  Future<bool> emailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Register new user with Firebase
  Future<void> register({
    required String email,
    required String password,
    required UserRole role,
    required String name,
    required String phone,
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      
      // Create user profile in Firestore
      final newUser = AppUser(
        id: uid,
        email: email,
        name: name,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(uid).set(newUser.toFirestore());
      
      _currentUser = newUser;
      
      // Save Session
      await StorageService().saveSession(uid);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Login with Firebase
  Future<void> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      
      // Get user profile from Firestore
      final doc = await _db.collection('users').doc(uid).get();
      
      if (doc.exists) {
        _currentUser = AppUser.fromFirestore(uid, doc.data()!);
      } else {
        // Profile doesn't exist, create one
        _currentUser = AppUser(
          id: uid,
          email: email,
          name: 'User',
          role: UserRole.driver,
        );
        await _db.collection('users').doc(uid).set(_currentUser!.toFirestore());
      }
      
      // Save Session
      await StorageService().saveSession(uid);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Logout
  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    await StorageService().clearSession();
    notifyListeners();
  }
  
  // Switch role
  Future<void> switchRole() async {
    if (_currentUser == null) return;
    
    _currentUser!.role = _currentUser!.role == UserRole.driver 
      ? UserRole.host 
      : UserRole.driver;
    
    await _db.collection('users').doc(_currentUser!.id).update({
      'role': _currentUser!.role == UserRole.host ? 'host' : 'driver',
    });
    
    notifyListeners();
  }

  // Toggle favorite
  Future<void> toggleFavorite(String spotId) async {
    if (_currentUser == null) return;
    
    if (_currentUser!.favoriteSpotIds.contains(spotId)) {
      _currentUser!.favoriteSpotIds = List.from(_currentUser!.favoriteSpotIds)..remove(spotId);
    } else {
      _currentUser!.favoriteSpotIds = List.from(_currentUser!.favoriteSpotIds)..add(spotId);
    }
    
    await _db.collection('users').doc(_currentUser!.id).update({
      'favoriteSpotIds': _currentUser!.favoriteSpotIds,
    });
    
    notifyListeners();
  }

  bool isFavorite(String spotId) {
    if (_currentUser == null) return false;
    return _currentUser!.favoriteSpotIds.contains(spotId);
  }

  List<String> get favoriteSpotIds {
    if (_currentUser == null) return [];
    return List.unmodifiable(_currentUser!.favoriteSpotIds);
  }

  // Update user profile
  Future<void> updateUserName(String newName) async {
    if (_currentUser == null) return;
    
    _currentUser = AppUser(
      id: _currentUser!.id,
      email: _currentUser!.email,
      name: newName,
      phone: _currentUser!.phone,
      role: _currentUser!.role,
      createdAt: _currentUser!.createdAt,
      totalIncome: _currentUser!.totalIncome,
      ownedSpotIds: _currentUser!.ownedSpotIds,
      bookingIds: _currentUser!.bookingIds,
      favoriteSpotIds: _currentUser!.favoriteSpotIds,
    );
    
    await _db.collection('users').doc(_currentUser!.id).update({'name': newName});
    
    notifyListeners();
  }

  // Handle Firebase Auth errors with Greek messages
  Exception _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Exception('Αυτό το email χρησιμοποιείται ήδη');
      case 'invalid-email':
        return Exception('Μη έγκυρο email');
      case 'weak-password':
        return Exception('Ο κωδικός είναι πολύ αδύναμος (min 6 χαρακτήρες)');
      case 'user-not-found':
        return Exception('Δεν υπάρχει χρήστης με αυτό το email');
      case 'wrong-password':
        return Exception('Λάθος κωδικός');
      case 'invalid-credential':
        return Exception('Λάθος email ή κωδικός');
      default:
        return Exception('Σφάλμα: ${e.message}');
    }
  }
}
