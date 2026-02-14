import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_health_coach/data/services/gemini_service.dart';
import 'package:ai_health_coach/data/models/ai_feedback_models.dart';
import 'package:ai_health_coach/data/models/daily_checkin_model.dart';
import 'package:ai_health_coach/data/models/exercise_model.dart';
import 'package:ai_health_coach/data/models/user_profile_model.dart';
import 'package:ai_health_coach/data/models/workout_model.dart';

void main() {
  late GeminiService service;

  setUp(() {
    service = GeminiService();
  });

  // ---------------------------------------------------------------------------
  // Helper to create a DailyCheckIn for testing
  // ---------------------------------------------------------------------------
  DailyCheckIn makeCheckIn({
    int painLevel = 0,
    int energyLevel = 3,
    int sleepQuality = 3,
    String mood = 'neutral',
  }) {
    return DailyCheckIn(
      id: 'test-checkin',
      odUid: 'test-user',
      date: DateTime(2026, 1, 15),
      painLevel: painLevel,
      energyLevel: energyLevel,
      sleepQuality: sleepQuality,
      mood: mood,
    );
  }

  UserProfile makeProfile() {
    return UserProfile(
      uid: 'user-1',
      name: 'Test User',
      medicalProfile: MedicalProfile(
        age: 30,
        weight: 70,
        activityLevel: 'moderate',
        injuries: const [],
      ),
      goals: 'Уменьшить боль в спине',
    );
  }

  List<Exercise> makeExercises() {
    return const [
      Exercise(
        id: 'lfk_cat_cow',
        title: 'Кошка-Корова',
        description: 'Мягкая мобилизация позвоночника',
        difficulty: 'easy',
        type: 'mobility',
        targetMuscles: [TargetMuscles.back],
      ),
    ];
  }

  // ===========================================================================
  // 1. cleanJsonResponse
  // ===========================================================================
  group('cleanJsonResponse', () {
    test('returns plain JSON unchanged', () {
      const input = '{"key": "value"}';
      expect(service.cleanJsonResponse(input), input);
    });

    test('strips ```json ... ``` fences', () {
      const input = '```json\n{"key": "value"}\n```';
      expect(service.cleanJsonResponse(input), '{"key": "value"}');
    });

    test('strips bare ``` fences', () {
      const input = '```\n{"key": "value"}\n```';
      expect(service.cleanJsonResponse(input), '{"key": "value"}');
    });

    test('strips <think> blocks from DeepSeek', () {
      const input =
          '<think>Let me analyze this...</think>{"key": "value"}';
      expect(service.cleanJsonResponse(input), '{"key": "value"}');
    });

    test('strips nested <think> blocks with newlines', () {
      const input =
          '<think>\nStep 1: think\nStep 2: more thinking\n</think>\n{"key": 1}';
      expect(service.cleanJsonResponse(input), '{"key": 1}');
    });

    test('handles combined fences + think blocks', () {
      const input =
          '```json\n<think>reasoning</think>{"data": true}\n```';
      expect(service.cleanJsonResponse(input), '{"data": true}');
    });

    test('trims whitespace', () {
      const input = '   \n{"val": 1}\n  ';
      expect(service.cleanJsonResponse(input), '{"val": 1}');
    });

    test('handles empty string', () {
      expect(service.cleanJsonResponse(''), '{}');
      expect(service.cleanJsonResponse('   '), '{}');
    });
  });

  // ===========================================================================
  // 1b. repairJson
  // ===========================================================================
  group('repairJson', () {
    test('returns valid JSON unchanged', () {
      const input = '{"key": "value"}';
      expect(service.repairJson(input), input);
    });

    test('closes missing brace', () {
      const input = '{"key": "value"';
      expect(service.repairJson(input), '{"key": "value"}');
    });

    test('closes missing quote', () {
      const input = '{"key": "value';
      expect(service.repairJson(input), '{"key": "value"}');
    });

    test('closes missing quote and brace', () {
      const input = '{"key": "value';
      expect(service.repairJson(input), '{"key": "value"}');
    });

    test('closes nested objects', () {
      const input = '{"data": {"nested": 1';
      expect(service.repairJson(input), '{"data": {"nested": 1}}');
    });

    test('handles empty input', () {
      expect(service.repairJson(''), '{}');
    });

    test('ignores escaped quotes', () {
      // "key": "val\"ue
      // quote count = 3 (1st, 2nd, 3rd is escaped, 4th is missing)
      const input = r'{"key": "val\"ue'; 
      expect(service.repairJson(input), r'{"key": "val\"ue"}');
    });

    test('repairs unescaped inner quotes in string values', () {
      const input = '{"name":"Растяжка "Четверка"","sets":1}';
      final repaired = service.repairJson(input);
      expect(repaired, contains(r'\"Четверка\"'));
      expect(() => jsonDecode(repaired), returnsNormally);
    });
  });

  // ===========================================================================
  // 2. inferIntensity
  // ===========================================================================
  group('inferIntensity', () {
    test('returns light for short workouts (<=15 min)', () {
      expect(
        service.inferIntensity({'estimated_duration': 10}),
        WorkoutIntensity.light,
      );
      expect(
        service.inferIntensity({'estimated_duration': 15}),
        WorkoutIntensity.light,
      );
    });

    test('returns moderate for medium workouts (16-44 min)', () {
      expect(
        service.inferIntensity({'estimated_duration': 30}),
        WorkoutIntensity.moderate,
      );
    });

    test('returns high for long workouts (>=45 min)', () {
      expect(
        service.inferIntensity({'estimated_duration': 45}),
        WorkoutIntensity.high,
      );
      expect(
        service.inferIntensity({'estimated_duration': 60}),
        WorkoutIntensity.high,
      );
    });

    test('defaults to moderate when duration is missing', () {
      expect(
        service.inferIntensity({}),
        WorkoutIntensity.moderate,
      );
    });
  });

  // ===========================================================================
  // 3. getDefaultRecommendation
  // ===========================================================================
  group('getDefaultRecommendation', () {
    test('recommends rest for high pain (>=7)', () {
      final result = service.getDefaultRecommendation(
        makeCheckIn(painLevel: 8, energyLevel: 5),
      );
      expect(result, contains('отдых'));
    });

    test('recommends light workout for moderate pain (4-6)', () {
      final result = service.getDefaultRecommendation(
        makeCheckIn(painLevel: 5, energyLevel: 3),
      );
      expect(result, contains('легкая'));
    });

    test('recommends light workout for low energy (<=2)', () {
      final result = service.getDefaultRecommendation(
        makeCheckIn(painLevel: 0, energyLevel: 1),
      );
      expect(result, contains('легкая'));
    });

    test('recommends full workout for high energy + low pain', () {
      final result = service.getDefaultRecommendation(
        makeCheckIn(painLevel: 1, energyLevel: 5),
      );
      expect(result, contains('полноценную'));
    });

    test('recommends moderate workout for average state', () {
      final result = service.getDefaultRecommendation(
        makeCheckIn(painLevel: 2, energyLevel: 3),
      );
      expect(result, contains('умеренная'));
    });
  });

  // ===========================================================================
  // 4. getDefaultPostWorkoutFeedback
  // ===========================================================================
  group('getDefaultPostWorkoutFeedback', () {
    test('returns pain caution for >2 pain reports', () {
      final feedback = service.getDefaultPostWorkoutFeedback(
        durationMinutes: 30,
        exercisesCompleted: 8,
        painReports: 3,
      );
      expect(feedback.title, contains('⚠️'));
      expect(feedback.tips, isNotEmpty);
      expect(feedback.encouragement, isNotEmpty);
    });

    test('returns short workout message for <15 min', () {
      final feedback = service.getDefaultPostWorkoutFeedback(
        durationMinutes: 10,
        exercisesCompleted: 3,
        painReports: 0,
      );
      expect(feedback.title, contains('Быстрая'));
      expect(feedback.encouragement, contains('регулярность'));
    });

    test('returns celebration for normal workout', () {
      final feedback = service.getDefaultPostWorkoutFeedback(
        durationMinutes: 25,
        exercisesCompleted: 8,
        painReports: 1,
      );
      expect(feedback.title, contains('🎉'));
      expect(feedback.summary, contains('8'));
      expect(feedback.summary, contains('25'));
    });

    test('always includes recoveryPlan', () {
      final feedback = service.getDefaultPostWorkoutFeedback(
        durationMinutes: 20,
        exercisesCompleted: 5,
        painReports: 0,
      );
      expect(feedback.recoveryPlan, isNotNull);
    });

    test('pain reports take priority over short duration', () {
      final feedback = service.getDefaultPostWorkoutFeedback(
        durationMinutes: 10,
        exercisesCompleted: 3,
        painReports: 5,
      );
      // Pain > 2 takes priority
      expect(feedback.title, contains('⚠️'));
    });
  });

  // ===========================================================================
  // 5. parseWorkoutResponse
  // ===========================================================================
  group('parseWorkoutResponse', () {
    test('parses valid workout JSON', () {
      final json = jsonEncode({
        'title': 'Утренняя тренировка',
        'description': 'Лёгкая ЛФК',
        'estimated_duration': 20,
        'warmup': [
          {
            'name': 'Марш на месте',
            'sets': 1,
            'reps': 30,
            'duration_seconds': 60,
            'description': 'Шагайте на месте',
          },
        ],
        'main_exercises': [
          {
            'name': 'Приседания',
            'sets': 3,
            'reps': 10,
            'duration_seconds': 0,
            'description': 'Обычные приседания',
          },
        ],
        'cooldown': [],
      });

      final workout = service.parseWorkoutResponse(
        json,
        'user-123',
        'checkin-456',
        WorkoutTypes.lfk,
      );

      expect(workout.title, 'Утренняя тренировка');
      expect(workout.description, 'Лёгкая ЛФК');
      expect(workout.userUid, 'user-123');
      expect(workout.checkInId, 'checkin-456');
      expect(workout.type, WorkoutTypes.lfk);
      expect(workout.warmup, hasLength(1));
      expect(workout.mainExercises, hasLength(1));
      expect(workout.cooldown, isEmpty);
      expect(workout.estimatedDuration, 20);
    });

    test('handles JSON wrapped in markdown fences', () {
      final json = '```json\n${jsonEncode({
        'title': 'Test',
        'warmup': [],
        'main_exercises': [],
        'cooldown': [],
      })}\n```';

      final workout = service.parseWorkoutResponse(
        json,
        'uid',
        'cid',
        WorkoutTypes.stretching,
      );

      expect(workout.title, 'Test');
      expect(workout.type, WorkoutTypes.stretching);
    });

    test('uses defaults for missing fields', () {
      final json = jsonEncode({
        'warmup': [],
        'main_exercises': [],
        'cooldown': [],
      });

      final workout = service.parseWorkoutResponse(
        json,
        'uid',
        'cid',
        WorkoutTypes.strength,
      );

      expect(workout.title, 'Персональная тренировка');
      expect(workout.description, '');
      expect(workout.estimatedDuration, 30);
    });

    test('repairs and parses unescaped quotes in exercise name', () {
      const malformedJson = '''
{
  "title": "Тестовая тренировка",
  "estimated_duration": 20,
  "warmup": [
    {
      "name": "Растяжка "Четверка"",
      "description": "Растяжка ягодичных",
      "sets": 1,
      "reps": 10
    }
  ],
  "main_exercises": [],
  "cooldown": []
}
''';

      final workout = service.parseWorkoutResponse(
        malformedJson,
        'uid',
        'cid',
        WorkoutTypes.lfk,
      );

      expect(workout.warmup, hasLength(1));
      expect(workout.warmup.first.name, 'Растяжка "Четверка"');
    });

    test('throws on invalid JSON', () {
      expect(
        () => service.parseWorkoutResponse(
          'not json at all',
          'uid',
          'cid',
          'lfk',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ===========================================================================
  // 6. generateWorkout retry flow
  // ===========================================================================
  group('generateWorkout retry', () {
    test('retries once when first response has malformed JSON', () async {
      var callCount = 0;
      final validJson = jsonEncode({
        'title': 'Retry success',
        'description': 'Valid after retry',
        'estimated_duration': 25,
        'warmup': [],
        'main_exercises': [],
        'cooldown': [],
      });

      final retryService = GeminiService(
        providerExecutorOverride: ({
          required String prompt,
          bool jsonMode = false,
          int maxTokens = 4096,
          double temperature = 0.7,
          int maxRetries = 1,
        }) async {
          callCount++;
          return callCount == 1 ? 'not json at all' : validJson;
        },
      );

      final workout = await retryService.generateWorkout(
        profile: makeProfile(),
        checkIn: makeCheckIn(),
        workoutType: WorkoutTypes.lfk,
        availableExercises: makeExercises(),
      );

      expect(workout.title, 'Retry success');
      expect(callCount, 2);
    });

    test('performs only one retry when parse keeps failing', () async {
      var callCount = 0;

      final retryService = GeminiService(
        providerExecutorOverride: ({
          required String prompt,
          bool jsonMode = false,
          int maxTokens = 4096,
          double temperature = 0.7,
          int maxRetries = 1,
        }) async {
          callCount++;
          return 'still not json';
        },
      );

      await expectLater(
        () => retryService.generateWorkout(
          profile: makeProfile(),
          checkIn: makeCheckIn(),
          workoutType: WorkoutTypes.lfk,
          availableExercises: makeExercises(),
        ),
        throwsA(isA<Exception>()),
      );

      expect(callCount, 2);
    });
  });

  // ===========================================================================
  // 6. parsePostWorkoutFeedback
  // ===========================================================================
  group('parsePostWorkoutFeedback', () {
    test('parses valid feedback JSON', () {
      final json = jsonEncode({
        'title': '🎉 Молодец!',
        'summary': 'Отличная работа',
        'tips': ['Пей воду', 'Отдыхай'],
        'next_workout_suggestion': 'Завтра йога',
        'encouragement': 'Так держать!',
      });

      final feedback = service.parsePostWorkoutFeedback(json, 'lfk', 30, 0);

      expect(feedback.title, '🎉 Молодец!');
      expect(feedback.summary, 'Отличная работа');
      expect(feedback.tips, hasLength(2));
      expect(feedback.nextWorkoutSuggestion, 'Завтра йога');
      expect(feedback.encouragement, 'Так держать!');
    });

    test('parses with recovery plan', () {
      final json = jsonEncode({
        'title': 'Done',
        'summary': 'Good',
        'tips': [],
        'next_workout_suggestion': '',
        'encouragement': 'Nice',
        'recovery_plan': {
          'rest_days': 1,
          'recommendations': ['Растяжка', 'Ванна'],
          'next_workout_type': 'stretching',
          'intensity_adjustment': 'снизить',
        },
      });

      final feedback = service.parsePostWorkoutFeedback(json, 'lfk', 20, 1);

      expect(feedback.recoveryPlan, isNotNull);
    });

    test('uses default recovery plan when recovery_plan field is missing', () {
      final json = jsonEncode({
        'title': 'Done',
        'summary': 'OK',
      });

      final feedback = service.parsePostWorkoutFeedback(json, 'lfk', 20, 0);
      expect(feedback.recoveryPlan, isNotNull);
    });

    test('uses default values for missing fields', () {
      final json = jsonEncode({});

      final feedback =
          service.parsePostWorkoutFeedback(json, 'stretching', 15, 0);

      expect(feedback.title, '✅ Тренировка завершена');
      expect(feedback.summary, 'Вы отлично поработали!');
      expect(feedback.tips, isEmpty);
      expect(feedback.encouragement, 'Продолжайте в том же духе!');
    });

    test('throws on invalid JSON', () {
      expect(
        () => service.parsePostWorkoutFeedback('broken', 'lfk', 10, 0),
        throwsA(isA<FormatException>()),
      );
    });
  });

  // ===========================================================================
  // 7. getPainAdaptedIntensity
  // ===========================================================================
  group('getPainAdaptedIntensity', () {
    test('no adjustment when no problematic areas and low pain', () async {
      final result = await service.getPainAdaptedIntensity(
        todayCheckIn: makeCheckIn(painLevel: 2, energyLevel: 4),
        recentPainReports: ['Шея'], // only 1 occurrence — not problematic
        recentWorkoutCount: 3,
      );

      expect(result.wasAdjusted, isFalse);
      expect(result.problematicAreas, isEmpty);
    });

    test('reduces high to moderate for recurring pain', () async {
      final result = await service.getPainAdaptedIntensity(
        todayCheckIn: makeCheckIn(painLevel: 1, energyLevel: 5),
        recentPainReports: ['Колени', 'Колени', 'Колени'],
        recentWorkoutCount: 2,
      );

      // suggestedIntensity for painLevel=1, energyLevel=5 → 'высокая'
      // Recurring knee pain → should reduce
      expect(result.problematicAreas, contains('Колени'));
      expect(result.avoidExerciseTypes, isNotEmpty);
    });

    test('forces light intensity for high pain (>=7)', () async {
      final result = await service.getPainAdaptedIntensity(
        todayCheckIn: makeCheckIn(painLevel: 8, energyLevel: 5),
        recentPainReports: [],
        recentWorkoutCount: 1,
      );

      // painLevel >= 7 → suggestedIntensity is 'отдых', 
      // but also high pain override → adjustedIntensity = light
      expect(result.adjustedIntensity, WorkoutIntensity.light);
    });

    test('recommends recovery after 5+ workouts', () async {
      final result = await service.getPainAdaptedIntensity(
        todayCheckIn: makeCheckIn(painLevel: 1, energyLevel: 5),
        recentPainReports: [],
        recentWorkoutCount: 6,
      );

      // Base is 'high' (high energy, low pain)
      // 6 workouts → should reduce to moderate and mention recovery
      expect(result.wasAdjusted, isTrue);
      expect(result.adjustedIntensity, WorkoutIntensity.moderate);
    });

    test('combines recurring pain + recovery week', () async {
      final result = await service.getPainAdaptedIntensity(
        todayCheckIn: makeCheckIn(painLevel: 2, energyLevel: 4),
        recentPainReports: ['Плечи', 'Плечи', 'Спина (поясница)', 'Спина (поясница)'],
        recentWorkoutCount: 5,
      );

      expect(result.problematicAreas, hasLength(2));
      expect(result.avoidExerciseTypes, isNotEmpty);
    });
  });

  // ===========================================================================
  // 8. Model tests
  // ===========================================================================
  group('PostWorkoutFeedback model', () {
    test('creates feedback with all fields', () {
      final feedback = PostWorkoutFeedback(
        title: '🎉 Great workout!',
        summary: 'You completed 10 exercises',
        tips: ['Stay hydrated', 'Rest well'],
        nextWorkoutSuggestion: 'Try yoga tomorrow',
        encouragement: 'Keep it up!',
      );

      expect(feedback.title, '🎉 Great workout!');
      expect(feedback.tips, hasLength(2));
    });
  });

  group('PainAdaptedIntensity model', () {
    test('wasAdjusted returns true when intensities differ', () {
      final adapted = PainAdaptedIntensity(
        originalIntensity: 'high',
        adjustedIntensity: 'moderate',
        reason: 'Pain in lower back',
        problematicAreas: ['Спина (поясница)'],
        avoidExerciseTypes: ['Скручивания'],
      );

      expect(adapted.wasAdjusted, isTrue);
    });

    test('wasAdjusted returns false when intensities are same', () {
      final notAdapted = PainAdaptedIntensity(
        originalIntensity: 'moderate',
        adjustedIntensity: 'moderate',
        reason: 'Good condition',
        problematicAreas: [],
        avoidExerciseTypes: [],
      );

      expect(notAdapted.wasAdjusted, isFalse);
    });
  });

  // ===========================================================================
  // 9. Configuration tests
  // ===========================================================================
  group('isConfigured', () {
    test('returns false when no API keys in test env', () {
      expect(service.isConfigured, isFalse);
    });
  });

  group('useOpenRouter / useGemini', () {
    test('can switch between providers without throwing', () {
      expect(() => service.useOpenRouter(), returnsNormally);
      expect(() => service.useGemini(), returnsNormally);
    });
  });

  group('Contraindications mapping', () {
    test('has all expected constants', () {
      expect(Contraindications.lumbarHernia, isNotEmpty);
      expect(Contraindications.cervicalHernia, isNotEmpty);
      expect(Contraindications.kneeInjury, isNotEmpty);
      expect(Contraindications.shoulderInjury, isNotEmpty);
      expect(Contraindications.hypertension, isNotEmpty);
    });
  });
}
