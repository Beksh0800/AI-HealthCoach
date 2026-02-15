import 'package:flutter/material.dart';
import 'dart:ui'; // For PlatformDispatcher
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/notification_service.dart';
import 'firebase_options.dart';
import 'presentation/blocs/auth/auth_cubit.dart';
import 'presentation/blocs/profile/profile_cubit.dart';
import 'presentation/blocs/checkin/checkin_cubit.dart';
import 'presentation/blocs/history/history_cubit.dart';
import 'presentation/blocs/workout/workout_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: .env file not found or could not be loaded: $e');
  }

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize dependencies
  await initDependencies();

  // Initialize notification service (re-schedules reminders on app start)
  try {
    await sl<NotificationService>().init().timeout(const Duration(seconds: 8));
  } catch (e) {
    debugPrint('Notification init skipped on startup: $e');
  }

  // Initialize locale data for Russian date formatting
  try {
    await initializeDateFormatting(
      'ru',
      null,
    ).timeout(const Duration(seconds: 8));
  } catch (e) {
    debugPrint('Locale init skipped on startup: $e');
  }

  runApp(const AIHealthCoachApp());
}

class AIHealthCoachApp extends StatelessWidget {
  const AIHealthCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider<ProfileCubit>(create: (_) => sl<ProfileCubit>()),
        BlocProvider<CheckInCubit>(create: (_) => sl<CheckInCubit>()),
        BlocProvider<HistoryCubit>(create: (_) => sl<HistoryCubit>()),
        BlocProvider<WorkoutCubit>(create: (_) => sl<WorkoutCubit>()),
      ],
      child: MaterialApp.router(
        title: 'AI-HealthCoach',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
