import '../models/exercise_model.dart';
import '../models/user_profile_model.dart';
import '../models/daily_checkin_model.dart';
import '../models/workout_model.dart';

/// Centralized AI prompt management for Health Coach
///
/// All prompts are in Russian as the app targets Russian-speaking users.
class AiPrompts {
  AiPrompts._();

  /// System prompt — defines the AI persona for all interactions
  static const String systemPrompt = '''
Ты — опытный AI-тренер и специалист по восстановительной медицине (ЛФК). 
Твоя специализация: персонализированные адаптивные тренировки для людей с ограничениями здоровья.

ПРАВИЛА:
1. Всегда отвечай на русском языке.
2. Безопасность пользователя — приоритет №1. При сомнениях выбирай более щадящий вариант.
3. Учитывай все медицинские ограничения и противопоказания.
4. Давай конкретные, практичные рекомендации.
5. Будь позитивным и мотивирующим, но реалистичным.
6. Если запрашивается JSON — отвечай ТОЛЬКО валидным JSON без markdown-обёрток.
''';

  /// Build workout generation prompt
  static String workoutGeneration({
    required UserProfile profile,
    required DailyCheckIn checkIn,
    required String workoutType,
    required List<Exercise> exercises,
    String? targetIntensity,
  }) {
    final intensity = targetIntensity ?? checkIn.suggestedIntensity;
    final medical = profile.medicalProfile;

    final injuriesText = medical.injuries.isNotEmpty
        ? medical.injuries.join(', ')
        : 'нет';

    final contraindicationsText = medical.contraindications.isNotEmpty
        ? medical.contraindications.join(', ')
        : 'нет';

    final workoutTypeLabel = WorkoutTypes.labels[workoutType] ?? 'ЛФК';

    final exercisesList = exercises
        .map((e) =>
            '- [${e.id}] ${e.title}: ${e.description} | '
            'Мышцы: ${e.targetMuscles.map((m) => TargetMuscles.labels[m] ?? m).join(", ")} | '
            'Сложность: ${e.difficulty}')
        .join('\n');

    return '''
Создай персонализированную тренировку типа "$workoutTypeLabel".

## ПРОФИЛЬ ПОЛЬЗОВАТЕЛЯ:
- Возраст: ${medical.age} лет
- Вес: ${medical.weight} кг
- Уровень активности: ${medical.activityLevel}
- Цели: ${profile.goals}
- Проблемы со здоровьем: $injuriesText
- Противопоказанные движения: $contraindicationsText

## СЕГОДНЯШНИЙ ОПРОС:
- Уровень боли: ${checkIn.painLevel}/10 (локализация: ${checkIn.painLocation})
- Энергия: ${checkIn.energyLevel}/5
- Сон: ${checkIn.sleepQuality}/5
- Настроение: ${checkIn.mood}

## ИНТЕНСИВНОСТЬ: $intensity

## ДОСТУПНЫЕ БЕЗОПАСНЫЕ УПРАЖНЕНИЯ:
$exercisesList

## ТРЕБОВАНИЯ:
1. Используй ТОЛЬКО упражнения из списка выше
2. Адаптируй нагрузку под текущий уровень боли и энергии
3. Разминка: 3-4 упражнения, Основная часть: 4-6 упражнений, Заминка: 2-3 упражнения
4. Указывай подходы, повторения или время для каждого упражнения
5. Добавь doctor_comment с персонализированным советом

## ФОРМАТ ОТВЕТА (строго JSON, без markdown):
{
  "title": "Название тренировки",
  "description": "Краткое описание (1-2 предложения)",
  "estimated_duration": число_минут,
  "warmup": [
    {
      "name": "Название НА РУССКОМ",
      "description": "Описание",
      "sets": 1,
      "reps": 10,
      "duration_seconds": 0,
      "rest_seconds": 15,
      "instructions": ["Шаг 1", "Шаг 2"],
      "difficulty": "easy",
      "target_muscles": ["мышца1"],
      "doctor_comment": "Персональный совет"
    }
  ],
  "main_exercises": [...],
  "cooldown": [...]
}
''';
  }

  /// Build exercise replacement prompt
  static String exerciseReplacement({
    required WorkoutExercise currentExercise,
    required String painLocation,
    required List<Exercise> safeExercises,
  }) {
    return '''
Пользователь испытывает боль в области "$painLocation" при выполнении "${currentExercise.name}".

Подбери ОДНО альтернативное упражнение:
1. Целевые мышцы: ${currentExercise.targetMuscles.join(', ')}
2. НЕ нагружает область боли ($painLocation)
3. Сложность: ${currentExercise.difficulty} или легче

ДОСТУПНЫЕ УПРАЖНЕНИЯ:
${safeExercises.map((e) => '- ${e.title}: ${e.description} | Мышцы: ${e.targetMuscles.join(", ")}').join('\n')}

Ответь ТОЛЬКО JSON:
{
  "name": "Название на русском",
  "description": "Описание",
  "sets": 1,
  "reps": 10,
  "duration_seconds": 0,
  "rest_seconds": 30,
  "instructions": ["Шаг 1", "Шаг 2"],
  "difficulty": "easy",
  "target_muscles": ["мышца1"],
  "doctor_comment": "Почему это безопаснее"
}
''';
  }

  /// Build exercise safety explanation prompt
  static String exerciseSafety({
    required String exerciseName,
    required String exerciseDescription,
    required UserProfile profile,
  }) {
    final medical = profile.medicalProfile;
    final injuriesText = medical.injuries.isNotEmpty
        ? medical.injuries.join(', ')
        : 'нет';

    return '''
ПРОФИЛЬ:
- Возраст: ${medical.age} лет
- Ограничения: $injuriesText

УПРАЖНЕНИЕ: $exerciseName — $exerciseDescription

Объясни в 2-3 предложениях простым языком:
1. Почему это упражнение БЕЗОПАСНО для данного пользователя
2. Какой эффект оно даст
3. На что обратить внимание при выполнении
''';
  }

  /// Build quick recommendation prompt
  static String quickRecommendation(DailyCheckIn checkIn) {
    return '''
Дай краткую рекомендацию (1-2 предложения) по тренировке на сегодня:
- Боль: ${checkIn.painLevel}/10 (${checkIn.painLocation})
- Энергия: ${checkIn.energyLevel}/5
- Сон: ${checkIn.sleepQuality}/5
- Настроение: ${checkIn.mood}

Ответь 1-2 предложениями.
''';
  }

  /// Build post-workout feedback prompt
  static String postWorkoutFeedback({
    required int durationMinutes,
    required int exercisesCompleted,
    required int totalExercises,
    required String workoutType,
    required int painReports,
    required UserProfile profile,
    List<String>? painLocations,
  }) {
    final completionRate = (exercisesCompleted / totalExercises * 100).round();
    final painLocationsText = painLocations?.join(', ') ?? 'нет';

    return '''
Дай отзыв о тренировке И ПЛАН ВОССТАНОВЛЕНИЯ.

ТРЕНИРОВКА:
- Тип: $workoutType
- Длительность: $durationMinutes мин
- Выполнено: $exercisesCompleted из $totalExercises ($completionRate%)
- Жалобы на боль: $painReports раз
- Локализация боли: $painLocationsText

ПОЛЬЗОВАТЕЛЬ:
- Возраст: ${profile.medicalProfile.age}
- Ограничения: ${profile.medicalProfile.injuries.join(', ')}

Ответь ТОЛЬКО JSON:
{
  "title": "Заголовок (эмодзи + 2-3 слова)",
  "summary": "Краткий итог 1-2 предложения",
  "tips": ["Совет 1", "Совет 2"],
  "next_workout_suggestion": "Рекомендация для след. тренировки",
  "encouragement": "Мотивационная фраза",
  "recovery_plan": {
    "rest_duration": "Время отдыха (напр: 24 часа)",
    "steps": [
      {
        "title": "Шаг",
        "description": "Подробно",
        "icon": "эмодзи",
        "timing": "Когда выполнить"
      }
    ],
    "nutrition_tip": "Совет по питанию",
    "sleep_tip": "Совет по сну"
  }
}

Recovery_plan должен включать: горячий душ, растяжку, питание, воду, лёд при болях, самомассаж, сон.
''';
  }
}
