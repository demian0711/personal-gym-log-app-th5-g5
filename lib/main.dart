import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bọc khởi tạo LocalStorage trong try-catch để tránh crash main
  try {
    await LocalStorageService().init();
  } catch (e) {
    debugPrint('Error initializing LocalStorageService: $e');
  }

  // Khởi tạo Firebase an toàn cho Web và Mobile
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    await Firebase.initializeApp(options: options);
  } catch (e) {
    debugPrint('Firebase initialization skip/error: $e');
  }

  // Chỉnh sửa cấu hình persistence an toàn cho Web và Mobile
  try {
    if (!kIsWeb) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    }
  } catch (e) {
    debugPrint('Error setting Firestore settings: $e');
  }

  // Bọc khởi tạo NotificationService trong try-catch
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('Error initializing NotificationService: $e');
  }

  runApp(const PersonalGymLogApp());
}
