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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for Fuchsia.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCuPO7lkAT7U2srmkztZBUQQAAC629L8vQ',
    appId: '1:977017835481:web:64e113c7519d98151693c8',
    messagingSenderId: '977017835481',
    projectId: 'stockflutter-e33e6',
    authDomain: 'stockflutter-e33e6.firebaseapp.com',
    storageBucket: 'stockflutter-e33e6.firebasestorage.app',
    measurementId: 'G-WT6ZLP1TEK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_PLACEHOLDER_REPLACED_BY_NATIVE_CONFIG',
    appId: '1:977017835481:android:2d5b1a9da79383091693c8',
    messagingSenderId: '977017835481',
    projectId: 'stockflutter-e33e6',
    storageBucket: 'stockflutter-e33e6.firebasestorage.app',
  );
}
