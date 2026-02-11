import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ai_health_coach/presentation/blocs/workout/workout_cubit.dart';
import 'package:ai_health_coach/data/services/gemini_service.dart';
import 'package:ai_health_coach/data/services/workout_persistence_service.dart';
import 'package:ai_health_coach/data/repositories/exercise_repository.dart';
import 'package:ai_health_coach/data/services/workout_analytics_service.dart';
import 'package:ai_health_coach/data/services/workout_cache_service.dart';
import 'package:ai_health_coach/data/models/workout_model.dart';

// Mocks
class MockGeminiService extends Mock implements GeminiService {}
class MockExerciseRepository extends Mock implements ExerciseRepository {}
class MockWorkoutPersistenceService extends Mock implements WorkoutPersistenceService {}
class MockWorkoutAnalyticsService extends Mock implements WorkoutAnalyticsService {}
class MockWorkoutCacheService extends Mock implements WorkoutCacheService {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// Test data
final testWorkout = Workout(
  id: 'test-workout-id',
  userUid: 'test-uid',
  title: 'Test Workout',
  description: 'A test workout',
  type: 'lfk',
  intensity: 'moderate',
  estimatedDuration: 30,
  warmup: [
    WorkoutExercise(
      name: 'Stretching',
      description: 'Basic stretch',
      sets: 1,
      reps: 10,
    ),
  ],
  mainExercises: [
    WorkoutExercise(
      name: 'Exercise 1',
      description: 'Main exercise',
      sets: 3,
      reps: 12,
    ),
    WorkoutExercise(
      name: 'Exercise 2',
      description: 'Second exercise',
      sets: 2,
      reps: 10,
    ),
  ],
  cooldown: [
    WorkoutExercise(
      name: 'Cool down stretch',
      description: 'Final stretch',
      sets: 1,
      durationSeconds: 60,
    ),
  ],
);

void main() {
  late WorkoutCubit workoutCubit;
  late MockGeminiService mockGeminiService;
  late MockExerciseRepository mockExerciseRepository;
  late MockWorkoutPersistenceService mockPersistenceService;
  late MockWorkoutAnalyticsService mockAnalyticsService;
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockGeminiService = MockGeminiService();
    mockExerciseRepository = MockExerciseRepository();
    mockPersistenceService = MockWorkoutPersistenceService();
    mockAnalyticsService = MockWorkoutAnalyticsService();
    mockFirestore = MockFirebaseFirestore();
    
    // Set up default mocks
    when(() => mockPersistenceService.clearWorkoutProgress())
        .thenAnswer((_) async {});
    when(() => mockPersistenceService.saveWorkoutProgress(
          workoutId: any(named: 'workoutId'),
          exerciseIndex: any(named: 'exerciseIndex'),
          currentSet: any(named: 'currentSet'),
          elapsedSeconds: any(named: 'elapsedSeconds'),
        )).thenAnswer((_) async {});
    
    workoutCubit = WorkoutCubit(
      geminiService: mockGeminiService,
      exerciseRepository: mockExerciseRepository,
      persistenceService: mockPersistenceService,
      analyticsService: mockAnalyticsService,
      cacheService: MockWorkoutCacheService(),
      firestore: mockFirestore,
    );
  });

  tearDown(() {
    workoutCubit.close();
  });

  group('WorkoutCubit', () {
    test('initial state is WorkoutInitial', () {
      expect(workoutCubit.state, const WorkoutInitial());
    });

    group('startWorkout', () {
      blocTest<WorkoutCubit, WorkoutState>(
        'emits WorkoutInProgress when starting from WorkoutReady',
        build: () => workoutCubit,
        seed: () => WorkoutReady(testWorkout),
        act: (cubit) => cubit.startWorkout(),
        expect: () => [
          isA<WorkoutInProgress>()
              .having((s) => s.workout, 'workout', testWorkout)
              .having((s) => s.currentExerciseIndex, 'currentExerciseIndex', 0),
        ],
      );

      blocTest<WorkoutCubit, WorkoutState>(
        'does nothing when not in WorkoutReady state',
        build: () => workoutCubit,
        seed: () => const WorkoutInitial(),
        act: (cubit) => cubit.startWorkout(),
        expect: () => [],
      );
    });

    group('completeSet', () {
      blocTest<WorkoutCubit, WorkoutState>(
        'moves to rest when more sets remaining',
        build: () => workoutCubit,
        seed: () => WorkoutInProgress(
          workout: testWorkout,
          currentExerciseIndex: 1, // Exercise with 3 sets
          currentSet: 1,
        ),
        act: (cubit) => cubit.completeSet(),
        expect: () => [
          isA<WorkoutInProgress>()
              .having((s) => s.currentSet, 'currentSet', 2)
              .having((s) => s.isResting, 'isResting', true),
        ],
      );
    });

    group('finishRest', () {
      blocTest<WorkoutCubit, WorkoutState>(
        'sets isResting to false',
        build: () => workoutCubit,
        seed: () => WorkoutInProgress(
          workout: testWorkout,
          currentExerciseIndex: 0,
          currentSet: 2,
          isResting: true,
        ),
        act: (cubit) => cubit.finishRest(),
        expect: () => [
          isA<WorkoutInProgress>().having((s) => s.isResting, 'isResting', false),
        ],
      );
    });

    group('skipExercise', () {
      blocTest<WorkoutCubit, WorkoutState>(
        'moves to next exercise',
        build: () => workoutCubit,
        seed: () => WorkoutInProgress(
          workout: testWorkout,
          currentExerciseIndex: 0,
          currentSet: 1,
        ),
        act: (cubit) => cubit.skipExercise(),
        expect: () => [
          isA<WorkoutInProgress>()
              .having((s) => s.currentExerciseIndex, 'currentExerciseIndex', 1)
              .having((s) => s.currentSet, 'currentSet', 1),
        ],
      );
    });

    group('previousExercise', () {
      blocTest<WorkoutCubit, WorkoutState>(
        'goes back to previous exercise',
        build: () => workoutCubit,
        seed: () => WorkoutInProgress(
          workout: testWorkout,
          currentExerciseIndex: 2,
          currentSet: 1,
        ),
        act: (cubit) => cubit.previousExercise(),
        expect: () => [
          isA<WorkoutInProgress>()
              .having((s) => s.currentExerciseIndex, 'currentExerciseIndex', 1),
        ],
      );

      blocTest<WorkoutCubit, WorkoutState>(
        'does nothing when at first exercise',
        build: () => workoutCubit,
        seed: () => WorkoutInProgress(
          workout: testWorkout,
          currentExerciseIndex: 0,
          currentSet: 1,
        ),
        act: (cubit) => cubit.previousExercise(),
        expect: () => [],
      );
    });

    group('reportPain', () {
      blocTest<WorkoutCubit, WorkoutState>(
        'emits WorkoutPainReported state',
        build: () => workoutCubit,
        seed: () => WorkoutInProgress(
          workout: testWorkout,
          currentExerciseIndex: 1,
        ),
        act: (cubit) => cubit.reportPain(),
        expect: () => [
          isA<WorkoutPainReported>()
              .having((s) => s.currentExerciseIndex, 'exerciseIndex', 1),
        ],
      );
    });

    group('cancelPainReport', () {
      blocTest<WorkoutCubit, WorkoutState>(
        'returns to WorkoutInProgress state',
        build: () => workoutCubit,
        seed: () => WorkoutPainReported(
          workout: testWorkout,
          currentExerciseIndex: 1,
          elapsedSeconds: 150,
        ),
        act: (cubit) => cubit.cancelPainReport(),
        expect: () => [
          isA<WorkoutInProgress>()
              .having((s) => s.currentExerciseIndex, 'exerciseIndex', 1),
        ],
      );
    });

    group('cancelWorkout', () {
      blocTest<WorkoutCubit, WorkoutState>(
        'resets to WorkoutInitial and clears persistence',
        build: () => workoutCubit,
        seed: () => WorkoutInProgress(workout: testWorkout),
        act: (cubit) => cubit.cancelWorkout(),
        expect: () => [const WorkoutInitial()],
        verify: (_) {
          verify(() => mockPersistenceService.clearWorkoutProgress()).called(1);
        },
      );
    });

    group('reset', () {
      blocTest<WorkoutCubit, WorkoutState>(
        'resets to WorkoutInitial and clears persistence',
        build: () => workoutCubit,
        seed: () => WorkoutCompleted(
          workout: testWorkout,
          totalDurationSeconds: 1800,
        ),
        act: (cubit) => cubit.reset(),
        expect: () => [const WorkoutInitial()],
        verify: (_) {
          verify(() => mockPersistenceService.clearWorkoutProgress()).called(1);
        },
      );
    });
  });
}
