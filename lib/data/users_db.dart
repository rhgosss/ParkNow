import '../models/app_user.dart';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsersDb {
  
  // Keep using SharedPreferences ONLY for "current login session" (id)
  static const _kCurrentUserId = "current_user_id";

  Future<Database> get _db async => await DatabaseHelper().database;

  Future<List<AppUser>> getAllUsers() async {
    final db = await _db;
    final maps = await db.query('users');
    return maps.map((e) => AppUser.fromMap(e)).toList();
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final db = await _db;

    // Check if email exists
    final existing = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (existing.isNotEmpty) {
      throw Exception("Υπάρχει ήδη χρήστης με αυτό το email.");
    }

    final user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      password: password,
      role: role,
    );

    await db.insert('users', user.toMap());

    // Auto login
    await setCurrentUser(user.id);

    return user;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final db = await _db;
    
    final maps = await db.query(
      'users',
      where: 'LOWER(email) = ? AND password = ?',
      whereArgs: [email.toLowerCase(), password],
    );

    if (maps.isEmpty) {
      throw Exception("Λάθος email ή κωδικός.");
    }

    final user = AppUser.fromMap(maps.first);
    await setCurrentUser(user.id);
    return user;
  }

  Future<void> setCurrentUser(String userId) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kCurrentUserId, userId);
  }

  Future<AppUser?> getCurrentUser() async {
    final sp = await SharedPreferences.getInstance();
    final id = sp.getString(_kCurrentUserId);
    if (id == null) return null;

    final db = await _db;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return AppUser.fromMap(maps.first);
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kCurrentUserId);
  }

  Future<void> deleteUser(String id) async {
    final db = await _db;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllUsers() async {
    final db = await _db;
    await db.delete('users');
    await logout();
  }
}
