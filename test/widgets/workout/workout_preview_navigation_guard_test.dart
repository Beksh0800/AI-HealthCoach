import 'package:ai_health_coach/data/models/workout_model.dart';
import 'package:ai_health_coach/gen/app_localizations.dart';
import 'package:ai_health_coach/presentation/blocs/workout/workout_cubit.dart';
import 'package:ai_health_coach/presentation/pages/workout/workout_preview_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockWorkoutCubit extends Mock implements WorkoutCubit {}

class _PushCounterObserver extends NavigatorObserver {
  int playerPushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == 'player') {
      playerPushes += 1;
    }
    super.didPush(route, previousRoute);
  }
}

void main() {
  late MockWorkoutCubit workoutCubit;
  late _PushCounterObserver observer;

  final testWorkout = Workout(
    id: 'workout-1',
    userUid: 'user-1',
    title: 'Тестовая тренировка',
    description: 'Описание',
    type: 'lfk',
    intensity: 'moderate',
    estimatedDuration: 20,
    warmup: const [],
    mainExercises: [
      WorkoutExercise(
        name: 'Bird dog',
        description: 'Сохраняй нейтральную спину и дыши ровно.',
        sets: 2,
        reps: 10,
      ),
    ],
    cooldown: const [],
  );

  WorkoutInProgress inProgressState() => WorkoutInProgress(
    workout: testWorkout,
    currentExerciseIndex: 0,
    currentSet: 1,
    isResting: false,
    elapsedSeconds: 12,
  );

  Widget buildApp() {
    final router = GoRouter(
      initialLocation: '/preview',
      observers: [observer],
      routes: [
        GoRoute(
          path: '/preview',
          name: 'preview',
          builder: (context, state) => BlocProvider<WorkoutCubit>.value(
            value: workoutCubit,
            child: const WorkoutPreviewPage(),
          ),
        ),
        GoRoute(
          path: '/workout-player',
          name: 'player',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('player-screen'))),
        ),
      ],
    );

    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }

  setUp(() {
    workoutCubit = MockWorkoutCubit();
    observer = _PushCounterObserver();
    when(() => workoutCubit.close()).thenAnswer((_) async {});

    final readyState = WorkoutReady(testWorkout);

    whenListen(
      workoutCubit,
      Stream<WorkoutState>.fromIterable([
        inProgressState(),
        readyState,
        inProgressState(),
      ]),
      initialState: readyState,
    );
    when(() => workoutCubit.state).thenReturn(readyState);
  });

  testWidgets(
    'WorkoutPreviewPage делает только один push в player при повторных emissions',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('player-screen'), findsOneWidget);
      expect(observer.playerPushes, 1);
    },
  );
}
