import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/config/cloudinary_config.dart';
import 'core/theme/app_theme.dart';
import 'features/analytics/data/models/workout_model_mapper.dart';
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
              firestoreService: ProgressPhotoFirestoreService(),
              cloudinaryService: CloudinaryService(
                cloudName: CloudinaryConfig.cloudName,
                uploadPreset: CloudinaryConfig.uploadPreset,
              ),
            ),
          ),
          update: (_, auth, provider) {
            final p =
                provider ??
                ProgressPhotoProvider(
                  ProgressPhotoRepositoryImpl(
                    firestoreService: ProgressPhotoFirestoreService(),
                    cloudinaryService: CloudinaryService(
                      cloudName: CloudinaryConfig.cloudName,
                      uploadPreset: CloudinaryConfig.uploadPreset,
                    ),
                  ),
                );
            p.bindUser(auth.currentUser?.id);
            return p;
          },
        ),
        ChangeNotifierProxyProvider<WorkoutProvider, AnalyticsProvider>(
          create: (_) => AnalyticsProvider(AnalyticsService()),
          update: (_, workout, analytics) {
            final a = analytics ?? AnalyticsProvider(AnalyticsService());
            a.updateFromWorkouts(
              workout.history.map((w) => w.toAnalyticsModel()).toList(),
            );
            return a;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Personal Gym Log',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
            locale: const Locale('vi', 'VN'),
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
