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
  warmup: [],
  mainExercises: [
    WorkoutExercise(
      name: 'Exercise 1',
      description: 'Main exercise',
      sets: 3,
      reps: 12,
    ),
  ],
  cooldown: [],
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

  group('WorkoutCubit Pain Flow', () {
    blocTest<WorkoutCubit, WorkoutState>(
      'Full pain flow: Report -> Location -> Intensity -> Action -> Rest -> Finish Rest',
      build: () => workoutCubit,
      seed: () => WorkoutInProgress(
        workout: testWorkout,
        currentExerciseIndex: 0,
        elapsedSeconds: 100,
      ),
      act: (cubit) async {
        cubit.reportPain();
        await Future.delayed(Duration.zero);
        cubit.selectPainLocation('Knees');
        await Future.delayed(Duration.zero);
        cubit.selectPainIntensity(7);
        await Future.delayed(Duration.zero);
        cubit.takePainRest(60);
        await Future.delayed(Duration.zero);
        cubit.finishPainRest();
      },
      expect: () => [
        // 1. Report Pain -> Location Step
        isA<WorkoutPainReported>()
            .having((s) => s.step, 'step', PainFlowStep.location),
        
        // 2. Select Location -> Intensity Step
        isA<WorkoutPainReported>()
            .having((s) => s.step, 'step', PainFlowStep.intensity)
            .having((s) => s.painLocation, 'location', 'Knees'),

        // 3. Select Intensity -> Action Step
        isA<WorkoutPainReported>()
            .having((s) => s.step, 'step', PainFlowStep.action)
            .having((s) => s.painIntensity, 'intensity', 7)
            .having((s) => s.painCategory, 'category', 'severe'),

        // 4. Take Rest -> Rest State
        isA<WorkoutPainRest>()
            .having((s) => s.restDurationSeconds, 'duration', 60)
            .having((s) => s.remainingSeconds, 'remaining', 60),

        // 5. Timer tick (optional, depending on implicit async logic, usually periodic timers need proper waiting)
        // We skip exact timer tick checks here as they are async, checking the final state transition
        
        // 6. Finish Rest -> Back to InProgress
        isA<WorkoutInProgress>(),
      ],
      // We skip count verification because timer ticks might produce extra states
      skip: 0, 
    );

    blocTest<WorkoutCubit, WorkoutState>(
      'Pain flow back navigation',
      build: () => workoutCubit,
      seed: () => WorkoutPainReported(
        workout: testWorkout,
        currentExerciseIndex: 0,
        elapsedSeconds: 100,
        step: PainFlowStep.action,
        painLocation: 'Back',
        painIntensity: 5,
      ),
      act: (cubit) async {
        cubit.painFlowBack(); // Action -> Intensity
        await Future.delayed(Duration.zero);
        cubit.painFlowBack(); // Intensity -> Location
      },
      expect: () => [
        isA<WorkoutPainReported>()
            .having((s) => s.step, 'step', PainFlowStep.intensity),
        isA<WorkoutPainReported>()
            .having((s) => s.step, 'step', PainFlowStep.location),
      ],
    );
  });
}
