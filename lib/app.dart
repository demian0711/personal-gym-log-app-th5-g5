import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/config/cloudinary_config.dart';
import 'core/theme/app_theme.dart';
import 'features/analytics/domain/services/analytics_service.dart';
import 'features/analytics/presentation/providers/analytics_provider.dart';
import 'features/progress_photos/data/repositories/progress_photo_repository_impl.dart';
import 'features/progress_photos/data/services/cloudinary_service.dart';
import 'features/progress_photos/data/services/progress_photo_firestore_service.dart';
import 'features/progress_photos/presentation/providers/progress_photo_provider.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/data/services/profile_firestore_service.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/splash_screen.dart';
import 'services/local_storage_service.dart';

class PersonalGymLogApp extends StatefulWidget {
  const PersonalGymLogApp({super.key});

  @override
  State<PersonalGymLogApp> createState() => _PersonalGymLogAppState();
}

class _PersonalGymLogAppState extends State<PersonalGymLogApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize date formatting for Vietnamese locale
    initializeDateFormatting('vi_VN', null);
    // Allow current frame to render splash screen before checking initialization
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        home: const SplashScreen(),
        theme: ThemeData(useMaterial3: true),
      );
    }

    final storage = LocalStorageService();

    return MultiProvider(
      providers: [
        // Critical providers - load immediately
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, WorkoutProvider>(
          create: (_) => WorkoutProvider(storage),
          update: (_, auth, workout) {
            final provider = workout ?? WorkoutProvider(storage);
            provider.bindUser(auth.currentUser?.id);
            return provider;
          },
        ),

        // Non-critical providers - load lazily
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (_) => ProfileProvider(
            ProfileRepositoryImpl(
              ProfileFirestoreService(),
              CloudinaryService(
                cloudName: CloudinaryConfig.cloudName,
                uploadPreset: CloudinaryConfig.uploadPreset,
              ),
            ),
          ),
          update: (_, auth, profile) {
            final provider =
                profile ??
                ProfileProvider(
                  ProfileRepositoryImpl(
                    ProfileFirestoreService(),
                    CloudinaryService(
                      cloudName: CloudinaryConfig.cloudName,
                      uploadPreset: CloudinaryConfig.uploadPreset,
                    ),
                  ),
                );
            profile?.bindUser(
              userId: auth.currentUser?.id,
              email: auth.currentUser?.email ?? '',
              fallbackDisplayName: auth.currentUser?.name ?? '',
              photoUrl: auth.currentUser?.photoUrl,
            );
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, AnalyticsProvider>(
          create: (_) => AnalyticsProvider(AnalyticsService()),
          update: (_, auth, analytics) {
            final provider = analytics ?? AnalyticsProvider(AnalyticsService());
            provider.bindUser(auth.currentUser?.id);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProgressPhotoProvider>(
          create: (_) => ProgressPhotoProvider(
            ProgressPhotoRepositoryImpl(
              cloudinaryService: CloudinaryService(
                cloudName: CloudinaryConfig.cloudName,
                uploadPreset: CloudinaryConfig.uploadPreset,
              ),
              firestoreService: ProgressPhotoFirestoreService(),
            ),
          ),
          update: (_, auth, progressPhoto) {
            final provider =
                progressPhoto ??
                ProgressPhotoProvider(
                  ProgressPhotoRepositoryImpl(
                    cloudinaryService: CloudinaryService(
                      cloudName: CloudinaryConfig.cloudName,
                      uploadPreset: CloudinaryConfig.uploadPreset,
                    ),
                    firestoreService: ProgressPhotoFirestoreService(),
                  ),
                );
            progressPhoto?.bindUser(auth.currentUser?.id);
            return provider;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Personal Gym Log',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
