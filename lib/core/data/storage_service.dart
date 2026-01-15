import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/chat/chat_screen.dart'; // For ChatMessage model? No, I'll define DTOs or use existing models
import 'parking_service.dart'; // For Booking model

class StorageService {
  static const String keyBookings = 'bookings_data';
  static const String keyChats = 'chats_data';
  
  // Singleton
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    print('StorageService: Initialize called');
    if (_prefs != null) {
      print('StorageService: Already initialized');
      return;
    }
    _prefs = await SharedPreferences.getInstance();
    print('StorageService: Initialized. Keys: ${_prefs?.getKeys()}');
  }

  // --- BOOKINGS ---
  
  List<Map<String, dynamic>> loadBookings() {
    if (_prefs == null) return [];
    final String? jsonString = _prefs!.getString(keyBookings);
    print('StorageService: Loading bookings: $jsonString');
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return List<Map<String, dynamic>>.from(jsonList);
    } catch (e) {
      print('Error loading bookings: $e');
      return [];
    }
  }

  Future<void> saveBookings(List<Map<String, dynamic>> bookingsJson) async {
    if (_prefs == null) await init();
    try {
      final String jsonString = jsonEncode(bookingsJson);
      await _prefs!.setString(keyBookings, jsonString);
      print('StorageService: Saved ${bookingsJson.length} bookings.');
    } catch (e) {
      print('Error saving bookings: $e');
    }
  }

  // --- CHATS ---
  
  List<Map<String, dynamic>> loadChats() {
    if (_prefs == null) return [];
    final String? jsonString = _prefs!.getString(keyChats);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return List<Map<String, dynamic>>.from(jsonList);
    } catch (e) {
      print('Error loading chats: $e');
      return [];
    }
  }

  Future<void> saveChats(List<Map<String, dynamic>> chats) async {
    if (_prefs == null) await init();
    try {
      final String jsonString = jsonEncode(chats);
      await _prefs!.setString(keyChats, jsonString);
      print('StorageService: Saved ${chats.length} chats.');
    } catch (e) {
      print('Error saving chats: $e');
    }
  }

  // --- SESSION ---
  static const String keySession = 'user_session_id';

  Future<void> saveSession(String userId) async {
    if (_prefs == null) await init();
    await _prefs!.setString(keySession, userId);
  }

  String? getSession() {
    if (_prefs == null) return null;
    return _prefs!.getString(keySession);
  }

  Future<void> clearSession() async {
    if (_prefs == null) await init();
    await _prefs!.remove(keySession);
  }
}
