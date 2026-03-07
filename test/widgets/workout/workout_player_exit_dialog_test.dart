import 'package:ai_health_coach/data/models/workout_model.dart';
import 'package:ai_health_coach/gen/app_localizations.dart';
import 'package:ai_health_coach/presentation/blocs/workout/workout_cubit.dart';
import 'package:ai_health_coach/presentation/pages/workout/workout_player_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockWorkoutCubit extends Mock implements WorkoutCubit {}

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

  Widget buildPage() {
    final router = GoRouter(
      initialLocation: '/workout-player',
      routes: [
        GoRoute(
          path: '/workout-player',
          builder: (context, state) => BlocProvider<WorkoutCubit>.value(
            value: workoutCubit,
            child: WorkoutPlayerPage(),
          ),
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

  testWidgets('быстрые тапы по back не создают несколько exit-диалогов', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    final backButtonWidget = tester.widget<IconButton>(
      find.byKey(const Key('workout_player_back_button')),
    );
    expect(backButtonWidget.onPressed, isNotNull);

    backButtonWidget.onPressed!.call();
    backButtonWidget.onPressed!.call();
    backButtonWidget.onPressed!.call();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('workout_exit_confirmation_dialog')),
      findsOneWidget,
    );
  });

  testWidgets('закрытие exit-диалога работает с первого нажатия', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    final backButtonWidget = tester.widget<IconButton>(
      find.byKey(const Key('workout_player_back_button')),
    );
    expect(backButtonWidget.onPressed, isNotNull);
    backButtonWidget.onPressed!.call();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('workout_exit_confirmation_dialog')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('workout_exit_cancel_button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('workout_exit_confirmation_dialog')),
      findsNothing,
    );
  });
}
