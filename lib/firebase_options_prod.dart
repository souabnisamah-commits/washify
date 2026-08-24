// Production Firebase Options for client: washify-souteqsa
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDzLhKtN0CYGPqTXhWyjRKgeUfNeEtUhes',
    appId: '1:1086980819930:web:f15f6596e1e275ae90cee3',
    messagingSenderId: '1086980819930',
    projectId: 'washify-souteqsa',
    authDomain: 'washify-souteqsa.firebaseapp.com',
    storageBucket: 'washify-souteqsa.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDzLhKtN0CYGPqTXhWyjRKgeUfNeEtUhes',
    appId: '1:1086980819930:android:3ecf1f8efa137abf90cee3',
    messagingSenderId: '1086980819930',
    projectId: 'washify-souteqsa',
    storageBucket: 'washify-souteqsa.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDzLhKtN0CYGPqTXhWyjRKgeUfNeEtUhes',
    appId: '1:1086980819930:ios:90fb6e15142c303f90cee3',
    messagingSenderId: '1086980819930',
    projectId: 'washify-souteqsa',
    storageBucket: 'washify-souteqsa.firebasestorage.app',
    iosBundleId: 'com.example.washify',
  );
}
