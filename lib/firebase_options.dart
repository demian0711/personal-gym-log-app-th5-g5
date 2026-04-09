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
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBP5eoed3h79RF6U1fJWvK7QWMiVu84UN4',
    appId: '1:158847912768:android:31a2d03095aedf993588a5',
    messagingSenderId: '158847912768',
    projectId: 'personal-gym-log',
    storageBucket: 'personal-gym-log.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:ios:YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_PROJECT_NUMBER',
    projectId: 'YOUR_PROJECT_ID',
    databaseURL: 'https://YOUR_PROJECT_ID.firebasedatabase.app',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.personalGymLogApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDp72lb9dbMBKpD7O32TH_jHitV9AEzxZs',
    appId: '1:441371152901:web:771bdfb890daa8e740426c',
    messagingSenderId: '441371152901',
    projectId: 'btl-a886b',
    authDomain: 'btl-a886b.firebaseapp.com',
    storageBucket: 'btl-a886b.firebasestorage.app',
    measurementId: 'G-7SRX5KTN23',
  );
}
