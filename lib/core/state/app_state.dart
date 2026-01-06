import 'package:flutter/foundation.dart';

enum UserRole { parker, host }

class AppState extends ChangeNotifier {
  bool _loggedIn = false;
  bool _needsRoleSelection = false; // μόνο μετά από register
  UserRole? _role;

  bool get loggedIn => _loggedIn;
  bool get needsRoleSelection => _needsRoleSelection;
  UserRole get role => _role ?? UserRole.parker; // default για login demo

  void login({required String email, required String password}) {
    _loggedIn = true;
    _needsRoleSelection = false; // δεν ξαναρωτάμε role στο login
    _role ??= UserRole.parker;   // default
    notifyListeners();
  }

  void startRegister() {
    _loggedIn = true;
    _needsRoleSelection = true;  // ΜΟΝΟ στην εγγραφή
    _role = null;
    notifyListeners();
  }

  void setRole(UserRole role) {
    _role = role;
    _needsRoleSelection = false;
    notifyListeners();
  }

  void switchRole() {
    _role = (role == UserRole.parker) ? UserRole.host : UserRole.parker;
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    _needsRoleSelection = false;
    _role = null;
    notifyListeners();
  }
}
