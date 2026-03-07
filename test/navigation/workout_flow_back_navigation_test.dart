import 'package:ai_health_coach/core/router/app_router.dart';
import 'package:ai_health_coach/data/models/workout_model.dart';
import 'package:ai_health_coach/gen/app_localizations.dart';
import 'package:ai_health_coach/presentation/blocs/workout/workout_cubit.dart';
import 'package:ai_health_coach/presentation/pages/workout/workout_player_page.dart';
import 'package:ai_health_coach/presentation/pages/workout/workout_preview_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockWorkoutCubit extends Mock implements WorkoutCubit {}

void main() {
  final testWorkout = Workout(
    id: 'workout-1',
    userUid: 'user-1',
    title: 'Тестовая тренировка',
    description: 'Описание',
    type: 'lfk',
    intensity: 'moderate',
    estimatedDuration: 20,
    warmup: const [],
    mainExercises: const [
      WorkoutExercise(
        name: 'Bird dog',
        description: 'Сохраняй нейтральную спину и дыши ровно.',
        sets: 2,
        reps: 10,
      ),
    ],
    cooldown: const [],
  );

  Widget buildRouterApp(GoRouter router) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }

  group('Workout flow back navigation', () {
    testWidgets(
      'player pain/system back не попадает в preview и не приводит к not-found тупику',
      (tester) async {
        final cubit = MockWorkoutCubit();
        when(() => cubit.close()).thenAnswer((_) async {});
        addTearDown(() async => cubit.close());

        final painState = WorkoutPainReported(
          workout: testWorkout,
          currentExerciseIndex: 0,
          elapsedSeconds: 10,
          step: PainFlowStep.location,
        );

        when(() => cubit.state).thenReturn(painState);
        whenListen(
          cubit,
          const Stream<WorkoutState>.empty(),
          initialState: painState,
        );

        final router = GoRouter(
          initialLocation: '/preview',
          routes: [
            GoRoute(
              path: '/preview',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('preview-screen'))),
            ),
            GoRoute(
              path: AppRoutes.workoutPlayer,
              builder: (context, state) => BlocProvider<WorkoutCubit>.value(
                value: cubit,
                child: const WorkoutPlayerPage(),
              ),
            ),
          ],
        );

        await tester.pumpWidget(buildRouterApp(router));
        await tester.pumpAndSettle();

        expect(find.text('preview-screen'), findsOneWidget);

        router.push(AppRoutes.workoutPlayer);
        await tester.pumpAndSettle();

        expect(find.byType(WorkoutPlayerPage), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        verify(() => cubit.cancelPainReport()).called(1);
        expect(find.byType(WorkoutPlayerPage), findsOneWidget);
        expect(find.text('preview-screen'), findsNothing);
      },
    );

    testWidgets(
      'preview при невалидном state делает recovery на workout route вместо not-found',
      (tester) async {
        final cubit = MockWorkoutCubit();
        when(() => cubit.close()).thenAnswer((_) async {});
        addTearDown(() async => cubit.close());

        const invalidState = WorkoutInitial();
        when(() => cubit.state).thenReturn(invalidState);
        whenListen(
          cubit,
          const Stream<WorkoutState>.empty(),
          initialState: invalidState,
        );

        final router = GoRouter(
          initialLocation: AppRoutes.workoutPreview,
          routes: [
            GoRoute(
              path: AppRoutes.workout,
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('workout-root'))),
            ),
            GoRoute(
              path: AppRoutes.workoutPreview,
              builder: (context, state) => BlocProvider<WorkoutCubit>.value(
                value: cubit,
                child: const WorkoutPreviewPage(),
              ),
            ),
          ],
        );

        await tester.pumpWidget(buildRouterApp(router));
        await tester.pumpAndSettle();

        expect(find.text('workout-root'), findsOneWidget);
        expect(find.byType(WorkoutPreviewPage), findsNothing);
      },
    );

    testWidgets(
      'preview appbar back и system back ведут на один и тот же маршрут',
      (tester) async {
        Future<void> runCase({required bool useSystemBack}) async {
          final cubit = MockWorkoutCubit();
          when(() => cubit.close()).thenAnswer((_) async {});
          addTearDown(() async => cubit.close());

          final readyState = WorkoutReady(testWorkout);
          when(() => cubit.state).thenReturn(readyState);
          whenListen(
            cubit,
            const Stream<WorkoutState>.empty(),
            initialState: readyState,
          );

          final router = GoRouter(
            initialLocation: AppRoutes.workoutPreview,
            routes: [
              GoRoute(
                path: AppRoutes.workout,
                builder: (context, state) =>
                    const Scaffold(body: Center(child: Text('workout-root'))),
              ),
              GoRoute(
                path: AppRoutes.workoutPreview,
                builder: (context, state) => BlocProvider<WorkoutCubit>.value(
                  value: cubit,
                  child: const WorkoutPreviewPage(),
                ),
              ),
            ],
          );

          await tester.pumpWidget(buildRouterApp(router));
          await tester.pumpAndSettle();

          expect(find.byType(WorkoutPreviewPage), findsOneWidget);

          if (useSystemBack) {
            await tester.binding.handlePopRoute();
          } else {
            await tester.tap(find.byIcon(Icons.arrow_back));
          }
          await tester.pumpAndSettle();

          expect(find.text('workout-root'), findsOneWidget);
        }

        await runCase(useSystemBack: false);
        await runCase(useSystemBack: true);
      },
    );
  });
}
