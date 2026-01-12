// lib/core/state/app_state.dart
import 'package:flutter/foundation.dart';
import '../data/auth_repository.dart';

export '../data/auth_repository.dart' show UserRole;

class AppState extends ChangeNotifier {
  final AuthRepository _auth = AuthRepository();

  AppState() {
    _auth.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _auth.removeListener(notifyListeners);
    super.dispose();
  }

  bool get loggedIn => _auth.isLoggedIn;
  UserRole get role => _auth.currentUser?.role ?? UserRole.driver;
  AppUser? get currentUser => _auth.currentUser;
  
  bool get needsRoleSelection => false;

  Future<void> login(String email, String password) async {
    await _auth.login(email, password);
  }

  Future<void> register({
    required String email,
    required String password,
    required UserRole role,
    required String name,
    required String phone,
  }) async {
    await _auth.register(
      email: email,
      password: password,
      role: role,
      name: name,
      phone: phone,
    );
  }

  Future<void> logout() async {
    await _auth.logout();
  }

  Future<void> switchRole() async {
    await _auth.switchRole();
  }

  // Favorites
  Future<void> toggleFavorite(String spotId) async {
    await _auth.toggleFavorite(spotId);
  }

  bool isFavorite(String spotId) {
    return _auth.isFavorite(spotId);
  }

  List<String> get favoriteSpotIds => _auth.favoriteSpotIds;

  // Profile updates
  Future<void> updateUserName(String newName) async {
    await _auth.updateUserName(newName);
  }
}
