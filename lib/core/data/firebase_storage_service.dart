// lib/core/data/firebase_storage_service.dart
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  static final FirebaseStorageService _instance = FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads image bytes to Firebase Storage and returns the download URL
  Future<String?> uploadSpotImage({
    required Uint8List imageBytes,
    required String spotId,
  }) async {
    try {
      print('FirebaseStorageService: Starting upload for spot $spotId...');
      final ref = _storage.ref().child('spots/$spotId/main_image.jpg');
      
      // Upload the image with timeout
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Wait for upload with timeout (30 seconds)
      await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Upload timeout - check your internet connection');
        },
      );
      
      print('FirebaseStorageService: Upload complete, getting URL...');
      
      // Get the download URL
      final downloadUrl = await ref.getDownloadURL();
      print('FirebaseStorageService: Got URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('FirebaseStorageService ERROR: $e');
      return null;
    }
  }

  /// Deletes an image from Firebase Storage
  Future<void> deleteSpotImage(String spotId) async {
    try {
      final ref = _storage.ref().child('spots/$spotId/main_image.jpg');
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
