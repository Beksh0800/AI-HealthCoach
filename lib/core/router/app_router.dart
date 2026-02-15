import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import '../../data/services/analytics_service.dart';
import '../../presentation/pages/splash_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/checkin/checkin_page.dart';
import '../../presentation/pages/workout/workout_generation_page.dart';
import '../../presentation/pages/workout/workout_preview_page.dart';
import '../../presentation/pages/workout/workout_player_page.dart';
import '../../presentation/pages/history/history_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/widgets/scaffold_with_nav_bar.dart';

/// App routes definition
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String checkIn = '/check-in';
  static const String workout = '/workout';
  static const String workoutPreview = '/workout-preview';
  static const String workoutPlayer = '/workout-player';
  static const String profile = '/profile';
  static const String history = '/history';
  static const String settings = '/settings';
}

/// App Router configuration
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    observers: [
      sl<AnalyticsService>().getAnalyticsObserver(),
    ],
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',

        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',

        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',

        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',

        builder: (context, state) => const OnboardingPage(),
      ),
      
      // Stateful Nested Navigation (Bottom Nav Bar)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          
          // Branch 2: Workout Generation
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.workout,
                name: 'workout',
                builder: (context, state) {
                  final type = state.extra as String?;
                  return WorkoutGenerationPage(initialWorkoutType: type);
                },
              ),
            ],
          ),
          
          // Branch 3: History
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                name: 'history',
                builder: (context, state) => const HistoryPage(),
              ),
            ],
          ),
          
          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // Routes that should hide the bottom nav bar (push on top of root navigator)
      GoRoute(
        path: AppRoutes.checkIn,
        name: 'checkIn',

        pageBuilder: (context, state) {
          final type = state.extra as String?;
          return MaterialPage(
            key: state.pageKey,
            child: CheckInPage(initialWorkoutType: type),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.workoutPreview,
        name: 'workoutPreview',

        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const WorkoutPreviewPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.workoutPlayer,
        name: 'workoutPlayer',

        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const WorkoutPlayerPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',

        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SettingsPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Страница не найдена',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    ),
  );
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

