import 'package:flutter/material.dart';
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
 HEAD
import 'providers/theme_provider.dart';
  
import 'providers/utilities_provider.dart';
  HPT
import 'providers/workout_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'services/local_storage_service.dart';

class PersonalGymLogApp extends StatelessWidget {
  const PersonalGymLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = LocalStorageService();

    return MultiProvider(
      providers: [
 HEAD
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
  
        ChangeNotifierProvider(create: (_) => AuthProvider(storage)),
  HPT
        ChangeNotifierProxyProvider<AuthProvider, WorkoutProvider>(
          create: (_) => WorkoutProvider(storage),
          update: (_, auth, workout) {
            final provider = workout ?? WorkoutProvider(storage);
 HEAD
            provider.bindUser(auth.currentUser?.id);
            return provider;
          },
        ),
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
            provider.bindUser(
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
          update: (_, auth, photos) {
            final provider =
                photos ??
                ProgressPhotoProvider(
                  ProgressPhotoRepositoryImpl(
                    cloudinaryService: CloudinaryService(
                      cloudName: CloudinaryConfig.cloudName,
                      uploadPreset: CloudinaryConfig.uploadPreset,
                    ),
                    firestoreService: ProgressPhotoFirestoreService(),
                  ),
                );
  
  HPT
            provider.bindUser(auth.currentUser?.id);
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => UtilitiesProvider()),
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
