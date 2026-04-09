import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
main
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService().init();
  String? bootstrapErrorMessage;

 main

  // Bọc khởi tạo LocalStorage trong try-catch để tránh crash main
  try {

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on UnsupportedError catch (error) {
    bootstrapErrorMessage = error.message ?? error.toString();
  } on FirebaseException catch (error) {
    if (error.code != 'duplicate-app') {
      bootstrapErrorMessage = error.message ?? error.toString();
    }
  } catch (error) {
    bootstrapErrorMessage = error.toString();
  }

  if (bootstrapErrorMessage != null) {
    runApp(_BootstrapErrorApp(message: bootstrapErrorMessage));
    return;
  }

  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (_) {}

  if (!kIsWeb) {
    try {
      await NotificationService.instance.initialize();
    } catch (_) {}
  }


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
 main
  runApp(const PersonalGymLogApp());
}

class _BootstrapErrorApp extends StatelessWidget {
  final String message;

  const _BootstrapErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Khong the khoi dong ung dung tren nen tang nay',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nguyen nhan hien tai la cau hinh Firebase cho web/desktop '
                    'chua day du trong project.',
                  ),
                  const SizedBox(height: 12),
                  SelectableText(message),
                  const SizedBox(height: 16),
                  const SelectableText(
                    'Cach xu ly nhanh: chay `flutterfire configure` va them '
                    'FirebaseOptions cho web vao lib/firebase_options.dart.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
