import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_health_coach/core/router/tab_branch_navigation.dart';
import 'package:ai_health_coach/gen/app_localizations.dart';
import 'package:ai_health_coach/presentation/widgets/scaffold_with_nav_bar.dart';

const String _homePath = '/home';
const String _workoutPath = '/workout';
const String _historyPath = '/history';
const String _profilePath = '/profile';

void main() {
  testWidgets(
    'Home quick actions keep tab index synced for History and Workout',
    (tester) async {
      await tester.pumpWidget(_TestApp(router: _buildRouter()));
      await tester.pumpAndSettle();

      expect(find.text('Home tab'), findsOneWidget);
      _expectBottomNavIndex(tester, 0);

      await tester.tap(find.byKey(const Key('quickToHistory')));
      await tester.pumpAndSettle();

      expect(find.text('History tab'), findsOneWidget);
      _expectBottomNavIndex(tester, 2);

      await tester.tap(find.byKey(const Key('backHomeFromHistory')));
      await tester.pumpAndSettle();

      expect(find.text('Home tab'), findsOneWidget);
      _expectBottomNavIndex(tester, 0);

      await tester.tap(find.byKey(const Key('quickToWorkout')));
      await tester.pumpAndSettle();

      expect(find.text('Workout tab'), findsOneWidget);
      _expectBottomNavIndex(tester, 1);
    },
  );

  testWidgets('Direct go() to tab routes stays synchronized with bottom nav', (
    tester,
  ) async {
    await tester.pumpWidget(_TestApp(router: _buildRouter()));
    await tester.pumpAndSettle();

    expect(find.text('Home tab'), findsOneWidget);
    _expectBottomNavIndex(tester, 0);

    await tester.tap(find.byKey(const Key('directGoHistory')));
    await tester.pumpAndSettle();

    expect(find.text('History tab'), findsOneWidget);
    _expectBottomNavIndex(tester, 2);

    await tester.tap(find.byKey(const Key('backHomeFromHistory')));
    await tester.pumpAndSettle();

    expect(find.text('Home tab'), findsOneWidget);
    _expectBottomNavIndex(tester, 0);

    await tester.tap(find.byKey(const Key('directGoWorkout')));
    await tester.pumpAndSettle();

    expect(find.text('Workout tab'), findsOneWidget);
    _expectBottomNavIndex(tester, 1);
  });
}

void _expectBottomNavIndex(WidgetTester tester, int expected) {
  final navBar = tester.widget<BottomNavigationBar>(
    find.byType(BottomNavigationBar),
  );
  expect(navBar.currentIndex, expected);
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: _homePath,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _homePath,
                builder: (context, state) => const _HomeTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _workoutPath,
                builder: (context, state) => const _WorkoutTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _historyPath,
                builder: (context, state) => const _HistoryTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _profilePath,
                builder: (context, state) => const _ProfileTab(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Home tab'),
          const SizedBox(height: 8),
          ElevatedButton(
            key: const Key('quickToHistory'),
            onPressed: () => context.goToTabBranch(AppTabBranch.history),
            child: const Text('Quick to history'),
          ),
          ElevatedButton(
            key: const Key('quickToWorkout'),
            onPressed: () => context.goToTabBranch(AppTabBranch.workout),
            child: const Text('Quick to workout'),
          ),
          ElevatedButton(
            key: const Key('directGoHistory'),
            onPressed: () => context.go(_historyPath),
            child: const Text('Direct go history'),
          ),
          ElevatedButton(
            key: const Key('directGoWorkout'),
            onPressed: () => context.go(_workoutPath),
            child: const Text('Direct go workout'),
          ),
        ],
      ),
    );
  }
}

class _WorkoutTab extends StatelessWidget {
  const _WorkoutTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Workout tab'));
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('History tab'),
          const SizedBox(height: 8),
          ElevatedButton(
            key: const Key('backHomeFromHistory'),
            onPressed: () => context.goToTabBranch(AppTabBranch.home),
            child: const Text('Back home'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile tab'));
  }
}
