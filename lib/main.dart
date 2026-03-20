import 'package:flutter/material.dart';

import 'app.dart';
import 'services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = LocalStorageService();
  await storage.init();
  runApp(PersonalGymLogApp(storageService: storage));
}
