import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

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
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDoj1P6kzFrQsPpPYy8X2pUUQ636x8q6LI',
    appId: '1:787587737004:android:0f4060959e6a1e0b7b8609',
    messagingSenderId: '787587737004',
    projectId: 'notisboard',
    authDomain: 'notisboard.firebaseapp.com',
    storageBucket: 'notisboard.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDoj1P6kzFrQsPpPYy8X2pUUQ636x8q6LI',
    appId: '1:787587737004:android:0f4060959e6a1e0b7b8609',
    messagingSenderId: '787587737004',
    projectId: 'notisboard',
    storageBucket: 'notisboard.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCbtHbJUp7Vx21cK6GlXReCn4dnDjaiY3o',
    appId: '1:787587737004:ios:0da217d9e1aa3a1a7b8609',
    messagingSenderId: '787587737004',
    projectId: 'notisboard',
    storageBucket: 'notisboard.firebasestorage.app',
    iosBundleId: 'com.notisboard.mobile',
  );
}
