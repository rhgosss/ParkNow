// lib/core/firebase/firebase_options.dart
// Generated manually with user's Firebase project settings

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError('DefaultFirebaseOptions not configured for this platform.');
    }
  }

  // Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCe2JxiY16hg-pXPSmkxvtmGfc53MeW2es',
    appId: '1:743871600386:web:e18b2d4587f2b30715541b',
    messagingSenderId: '743871600386',
    projectId: 'parknow-ec535',
    storageBucket: 'parknow-ec535.firebasestorage.app',
    authDomain: 'parknow-ec535.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCe2JxiY16hg-pXPSmkxvtmGfc53MeW2es',
    appId: '1:743871600386:android:4bad4e216cdf888615541b',
    messagingSenderId: '743871600386',
    projectId: 'parknow-ec535',
    storageBucket: 'parknow-ec535.firebasestorage.app',
  );

  // iOS - θα χρειαστεί update αν προσθέσεις iOS app
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCe2JxiY16hg-pXPSmkxvtmGfc53MeW2es',
    appId: '1:743871600386:android:4bad4e216cdf888615541b',
    messagingSenderId: '743871600386',
    projectId: 'parknow-ec535',
    storageBucket: 'parknow-ec535.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  // Windows - για development
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCe2JxiY16hg-pXPSmkxvtmGfc53MeW2es',
    appId: '1:743871600386:android:4bad4e216cdf888615541b',
    messagingSenderId: '743871600386',
    projectId: 'parknow-ec535',
    storageBucket: 'parknow-ec535.firebasestorage.app',
  );
}

