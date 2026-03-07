import 'dart:async';

import 'package:ai_health_coach/data/models/workout_model.dart';
import 'package:ai_health_coach/gen/app_localizations.dart';
import 'package:ai_health_coach/presentation/blocs/workout/workout_cubit.dart';
import 'package:ai_health_coach/presentation/pages/workout/workout_player_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWorkoutCubit extends Mock implements WorkoutCubit {}

class _DialogPushObserver extends NavigatorObserver {
  int dialogPushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PopupRoute<dynamic>) {
      dialogPushes += 1;
    }
    super.didPush(route, previousRoute);
  }
}

void main() {
  late MockWorkoutCubit workoutCubit;

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

  Widget buildPage({List<NavigatorObserver> observers = const []}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: observers,
      home: BlocProvider<WorkoutCubit>.value(
        value: workoutCubit,
        child: WorkoutPlayerPage(),
      ),
    );
  }

  setUp(() {
    workoutCubit = MockWorkoutCubit();
    when(() => workoutCubit.close()).thenAnswer((_) async {});
    when(() => workoutCubit.getElapsedSeconds()).thenReturn(12);
    when(
      () => workoutCubit.explainExercise(
        any(),
        any(),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer((_) async => 'Localized insight');

    final initial = inProgressState();
    whenListen(
      workoutCubit,
      const Stream<WorkoutState>.empty(),
      initialState: initial,
    );
    when(() => workoutCubit.state).thenReturn(initial);
  });

  testWidgets('один тап по AI explain открывает один диалог', (tester) async {
    final observer = _DialogPushObserver();
    await tester.pumpWidget(buildPage(observers: [observer]));
    await tester.pumpAndSettle();

    final openButton = tester.widget<TextButton>(
      find.byKey(const Key('workout_ai_insight_open_button')),
    );
    openButton.onPressed!.call();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('workout_ai_insight_dialog')), findsOneWidget);
    expect(observer.dialogPushes, 1);
  });

  testWidgets(
    'быстрые множественные тапы не создают стек из нескольких AI-диалогов',
    (tester) async {
      final observer = _DialogPushObserver();
      await tester.pumpWidget(buildPage(observers: [observer]));
      await tester.pumpAndSettle();

      final openButton = tester.widget<TextButton>(
        find.byKey(const Key('workout_ai_insight_open_button')),
      );

      openButton.onPressed!.call();
      openButton.onPressed!.call();
      openButton.onPressed!.call();
      openButton.onPressed!.call();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('workout_ai_insight_dialog')),
        findsOneWidget,
      );
      expect(observer.dialogPushes, 1);

      await tester.tap(
        find.byKey(const Key('workout_ai_insight_close_button')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('workout_ai_insight_dialog')), findsNothing);
    },
  );

  testWidgets(
    'повторный trigger при уже открытом AI-диалоге идемпотентен (без повторного push)',
    (tester) async {
      final observer = _DialogPushObserver();
      await tester.pumpWidget(buildPage(observers: [observer]));
      await tester.pumpAndSettle();

      final openButton = tester.widget<TextButton>(
        find.byKey(const Key('workout_ai_insight_open_button')),
      );

      openButton.onPressed!.call();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('workout_ai_insight_dialog')),
        findsOneWidget,
      );
      expect(observer.dialogPushes, 1);

      openButton.onPressed!.call();
      openButton.onPressed!.call();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('workout_ai_insight_dialog')),
        findsOneWidget,
      );
      expect(observer.dialogPushes, 1);
    },
  );

  testWidgets(
    'AI-диалог не auto-close от фоновых WorkoutInProgress обновлений (таймер ticks)',
    (tester) async {
      final stateController = StreamController<WorkoutState>();
      final observer = _DialogPushObserver();
      final initial = inProgressState();
      var latestState = initial;

      whenListen(workoutCubit, stateController.stream, initialState: initial);
      when(() => workoutCubit.state).thenAnswer((_) => latestState);

      await tester.pumpWidget(buildPage(observers: [observer]));
      await tester.pumpAndSettle();

      final openButton = tester.widget<TextButton>(
        find.byKey(const Key('workout_ai_insight_open_button')),
      );
      openButton.onPressed!.call();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('workout_ai_insight_dialog')),
        findsOneWidget,
      );
      expect(observer.dialogPushes, 1);

      for (var i = 1; i <= 4; i++) {
        latestState = initial.copyWith(
          elapsedSeconds: initial.elapsedSeconds + i,
        );
        stateController.add(latestState);
        await tester.pump();

        expect(
          find.byKey(const Key('workout_ai_insight_dialog')),
          findsOneWidget,
        );
      }

      expect(observer.dialogPushes, 1);
      await stateController.close();
    },
  );

  testWidgets(
    'guard контроллер сохраняется при rebuild и не даёт повторно открыть AI-диалог',
    (tester) async {
      final stateController = StreamController<WorkoutState>();
      final observer = _DialogPushObserver();
      final initial = inProgressState();
      var latestState = initial;

      whenListen(workoutCubit, stateController.stream, initialState: initial);
      when(() => workoutCubit.state).thenAnswer((_) => latestState);

      await tester.pumpWidget(buildPage(observers: [observer]));
      await tester.pumpAndSettle();

      final openButton = tester.widget<TextButton>(
        find.byKey(const Key('workout_ai_insight_open_button')),
      );

      openButton.onPressed!.call();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('workout_ai_insight_dialog')),
        findsOneWidget,
      );
      expect(observer.dialogPushes, 1);

      latestState = initial.copyWith(currentSet: 2);
      stateController.add(latestState);
      await tester.pumpAndSettle();

      openButton.onPressed!.call();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('workout_ai_insight_dialog')),
        findsOneWidget,
      );
      expect(observer.dialogPushes, 1);

      await stateController.close();
    },
  );
}
