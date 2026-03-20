import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'services/local_storage_service.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  // Initialize local storage
  await LocalStorageService().init();

  // Set a default user ID (you can replace this with actual auth later)
  const defaultUserId = 'default_user';
  FirebaseService().setUserId(defaultUserId);

  runApp(const PersonalGymLogApp());
}
