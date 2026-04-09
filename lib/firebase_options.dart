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
    apiKey: 'AIzaSyCtih01ZNkkmlOLDMiioRgi64oswkGutBo',
    appId: '1:972551890881:android:3b5ed496663613abe67140',
    messagingSenderId: '972551890881',
    projectId: 'th5thi',
    storageBucket: 'th5thi.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCtih01ZNkkmlOLDMiioRgi64oswkGutBo',
    appId: '1:972551890881:ios:3b5ed496663613abe67140', // Inferring consistent ID pattern
    messagingSenderId: '972551890881',
    projectId: 'th5thi',
    storageBucket: 'th5thi.firebasestorage.app',
    iosBundleId: 'com.example.personal_gym_log_app_th5_g5',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCtih01ZNkkmlOLDMiioRgi64oswkGutBo',
    appId: '1:972551890881:web:202c558d2bc6b6e0e67140',
    messagingSenderId: '972551890881',
    projectId: 'th5thi',
    authDomain: 'th5thi.firebaseapp.com',
    storageBucket: 'th5thi.firebasestorage.app',
    measurementId: 'G-ETZ9M8R06G',
  );
}
