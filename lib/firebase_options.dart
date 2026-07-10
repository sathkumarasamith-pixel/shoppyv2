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
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCeJDSoEGUj066EDXXIcy2JulX1LuaFrYs',
    appId: '1:1059569518756:android:6d71442ee3493ca19c7e31',
    messagingSenderId: '1059569518756',
    projectId: 'shoppy-f6f81',
    authDomain: 'shoppy-f6f81.firebaseapp.com',
    storageBucket: 'shoppy-f6f81.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCeJDSoEGUj066EDXXIcy2JulX1LuaFrYs',
    appId: '1:1059569518756:ios:6d71442ee3493ca19c7e31',
    messagingSenderId: '1059569518756',
    projectId: 'shoppy-f6f81',
    authDomain: 'shoppy-f6f81.firebaseapp.com',
    storageBucket: 'shoppy-f6f81.firebasestorage.app',
    iosBundleId: 'com.example.shoppy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCeJDSoEGUj066EDXXIcy2JulX1LuaFrYs',
    appId: '1:1059569518756:ios:6d71442ee3493ca19c7e31',
    messagingSenderId: '1059569518756',
    projectId: 'shoppy-f6f81',
    authDomain: 'shoppy-f6f81.firebaseapp.com',
    storageBucket: 'shoppy-f6f81.firebasestorage.app',
    iosBundleId: 'com.example.shoppy',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCeJDSoEGUj066EDXXIcy2JulX1LuaFrYs',
    appId: '1:1059569518756:web:6d71442ee3493ca19c7e31',
    messagingSenderId: '1059569518756',
    projectId: 'shoppy-f6f81',
    authDomain: 'shoppy-f6f81.firebaseapp.com',
    storageBucket: 'shoppy-f6f81.firebasestorage.app',
  );
}