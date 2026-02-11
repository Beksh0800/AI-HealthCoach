import 'package:flutter_test/flutter_test.dart';

import 'package:ai_health_coach/data/models/user_profile_model.dart';
import 'package:ai_health_coach/data/models/daily_checkin_model.dart';
import 'package:ai_health_coach/data/models/exercise_model.dart';
import 'package:ai_health_coach/data/models/workout_model.dart';
import 'package:ai_health_coach/data/models/workout_history_model.dart';

// Test fixtures
final testProfile = UserProfile(
  uid: 'test-uid',
  name: 'Test User',
  email: 'test@example.com',
  goals: 'Improve flexibility',
  medicalProfile: MedicalProfile(
    age: 35,
    weight: 75.0,
    activityLevel: 'moderate',
    injuries: ['lower_back'],
    contraindications: ['avoid_heavy_lifting'],
  ),
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
);

final testCheckIn = DailyCheckIn(
  id: 'checkin-123',
  odUid: 'test-uid',
  date: DateTime(2024, 1, 15, 10, 30),
  painLevel: 3,
  painLocation: 'lower_back',
  energyLevel: 7,
  sleepQuality: 8,
  mood: 'good',
  currentSymptoms: ['fatigue'],
  notes: 'Test notes',
);

void main() {
  group('Workout Model Integration', () {
    test('allExercises returns correct order', () {
      final workout = Workout(
        id: 'w1',
        userUid: 'u1',
        title: 'Test',
        description: 'Test workout',
        type: 'lfk',
        intensity: 'moderate',
        estimatedDuration: 30,
        warmup: [WorkoutExercise(name: 'Warmup 1', description: 'd1')],
        mainExercises: [
          WorkoutExercise(name: 'Main 1', description: 'd2'),
          WorkoutExercise(name: 'Main 2', description: 'd3'),
        ],
        cooldown: [WorkoutExercise(name: 'Cooldown 1', description: 'd4')],
      );

      expect(workout.allExercises.length, 4);
      expect(workout.allExercises[0].name, 'Warmup 1');
      expect(workout.allExercises[1].name, 'Main 1');
      expect(workout.allExercises[3].name, 'Cooldown 1');
    });

    test('totalExercises calculates correctly', () {
      final workout = Workout(
        id: 'w1',
        userUid: 'u1',
        title: 'Test',
        description: 'Desc',
        type: 'lfk',
        intensity: 'light',
        estimatedDuration: 20,
        warmup: [WorkoutExercise(name: 'W1', description: 'd')],
        mainExercises: [
          WorkoutExercise(name: 'M1', description: 'd'),
          WorkoutExercise(name: 'M2', description: 'd'),
        ],
        cooldown: [],
      );

      expect(workout.totalExercises, 3);
    });

    test('copyWith preserves unmodified fields', () {
      final workout = Workout(
        id: 'w1',
        userUid: 'u1',
        title: 'Original',
        description: 'Desc',
        type: 'lfk',
        intensity: 'moderate',
        estimatedDuration: 30,
        warmup: [],
        mainExercises: [],
        cooldown: [],
      );

      final updated = workout.copyWith(title: 'Updated');

      expect(updated.title, 'Updated');
      expect(updated.id, workout.id);
      expect(updated.intensity, workout.intensity);
    });
  });

  group('WorkoutExercise', () {
    test('isTimeBased returns true for duration exercises', () {
      final exercise = WorkoutExercise(
        name: 'Plank',
        description: 'Hold position',
        sets: 3,
        durationSeconds: 30,
      );

      expect(exercise.isTimeBased, true);
    });

    test('isTimeBased returns false for rep exercises', () {
      final exercise = WorkoutExercise(
        name: 'Squats',
        description: 'Do squats',
        sets: 3,
        reps: 12,
      );

      expect(exercise.isTimeBased, false);
    });

    test('displayFormat shows correct format for reps', () {
      final exercise = WorkoutExercise(
        name: 'Exercise',
        description: 'd',
        sets: 3,
        reps: 10,
      );

      expect(exercise.displayFormat, '3 x 10');
    });

    test('toMap and fromMap roundtrip works', () {
      final exercise = WorkoutExercise(
        name: 'Test Exercise',
        description: 'Description',
        sets: 3,
        reps: 12,
        restSeconds: 45,
        difficulty: 'medium',
        targetMuscles: ['legs', 'core'],
        instructions: ['Step 1', 'Step 2'],
      );

      final map = exercise.toMap();
      final restored = WorkoutExercise.fromMap(map);

      expect(restored.name, exercise.name);
      expect(restored.sets, exercise.sets);
      expect(restored.reps, exercise.reps);
      expect(restored.targetMuscles, exercise.targetMuscles);
    });
  });

  group('UserProfile', () {
    test('copyWith creates new instance with updated fields', () {
      final updated = testProfile.copyWith(name: 'New Name');

      expect(updated.name, 'New Name');
      expect(updated.uid, testProfile.uid);
      expect(updated.medicalProfile.age, testProfile.medicalProfile.age);
    });

    test('toMap and fromMap roundtrip works', () {
      final map = testProfile.toMap();
      final restored = UserProfile.fromMap(map, testProfile.uid);

      expect(restored.name, testProfile.name);
      expect(restored.email, testProfile.email);
      expect(restored.medicalProfile.weight, testProfile.medicalProfile.weight);
    });

    test('MedicalProfile contains injury list', () {
      expect(testProfile.medicalProfile.injuries, contains('lower_back'));
    });
  });

  group('DailyCheckIn', () {
    test('copyWith preserves unmodified fields', () {
      final updated = testCheckIn.copyWith(painLevel: 5);

      expect(updated.painLevel, 5);
      expect(updated.energyLevel, testCheckIn.energyLevel);
      expect(updated.mood, testCheckIn.mood);
    });

    test('toMap includes all fields', () {
      final map = testCheckIn.toMap();

      expect(map['pain_level'], testCheckIn.painLevel);
      expect(map['energy_level'], testCheckIn.energyLevel);
      expect(map['mood'], testCheckIn.mood);
    });

    test('fromMap correctly parses data', () {
      final map = testCheckIn.toMap();
      final restored = DailyCheckIn.fromMap(map, testCheckIn.id);

      expect(restored.painLevel, testCheckIn.painLevel);
      expect(restored.currentSymptoms, testCheckIn.currentSymptoms);
    });
  });

  group('Exercise Model', () {
    test('isSafeFor returns false when contraindication matches', () {
      const exercise = Exercise(
        id: 'ex1',
        title: 'Heavy Squat',
        description: 'Deep squat',
        type: 'strength',
        difficulty: 'hard',
        targetMuscles: ['legs'],
        contraindications: ['deep_squats', 'heavy_weights'],
      );

      expect(exercise.isSafeFor(['deep_squats']), false);
    });

    test('isSafeFor returns true when no contraindication matches', () {
      const exercise = Exercise(
        id: 'ex1',
        title: 'Arm Circles',
        description: 'Gentle arm circles',
        type: 'warmup',
        difficulty: 'easy',
        targetMuscles: ['shoulders'],
        contraindications: [],
      );

      expect(exercise.isSafeFor(['deep_squats', 'heavy_weights']), true);
    });

    test('equipment constants exist', () {
      expect(Equipment.none, isNotEmpty);
      expect(Equipment.mat, isNotEmpty);
    });
  });

  group('WorkoutHistory', () {
    test('durationFormatted returns correct format', () {
      final history = WorkoutHistory(
        id: 'h1',
        workoutId: 'w1',
        userUid: 'u1',
        title: 'Workout',
        type: 'lfk',
        intensity: 'moderate',
        durationSeconds: 1830, // 30 minutes 30 seconds
        exercisesCompleted: 10,
        completedAt: DateTime.now(),
      );

      expect(history.durationFormatted, contains('30'));
    });
  });

  group('WorkoutTypes', () {
    test('labels contain all types', () {
      expect(WorkoutTypes.labels[WorkoutTypes.lfk], isNotEmpty);
      expect(WorkoutTypes.labels[WorkoutTypes.stretching], isNotEmpty);
      expect(WorkoutTypes.labels[WorkoutTypes.strength], isNotEmpty);
    });

    test('descriptions contain all types', () {
      expect(WorkoutTypes.descriptions[WorkoutTypes.lfk], isNotEmpty);
      expect(WorkoutTypes.descriptions[WorkoutTypes.cardio], isNotEmpty);
    });
  });

  group('WorkoutIntensity', () {
    test('labels contain all intensities', () {
      expect(WorkoutIntensity.labels[WorkoutIntensity.light], isNotEmpty);
      expect(WorkoutIntensity.labels[WorkoutIntensity.moderate], isNotEmpty);
      expect(WorkoutIntensity.labels[WorkoutIntensity.high], isNotEmpty);
      expect(WorkoutIntensity.labels[WorkoutIntensity.rest], isNotEmpty);
    });
  });
}
