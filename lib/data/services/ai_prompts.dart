import '../models/exercise_model.dart';
import '../models/user_profile_model.dart';
import '../models/daily_checkin_model.dart';
import '../models/workout_model.dart';

/// Centralized AI prompt management for Health Coach
///
/// Prompts enforce response language based on current app locale.
class AiPrompts {
  AiPrompts._();

  static String normalizeLanguageCode(String languageCode) {
    final normalized = languageCode.trim().toLowerCase();
    if (normalized.startsWith('en')) return 'en';
    if (normalized.startsWith('kk')) return 'kk';
    return 'ru';
  }

  static String _languageName(String languageCode) {
    switch (normalizeLanguageCode(languageCode)) {
      case 'en':
        return 'English';
      case 'kk':
        return 'Kazakh';
      default:
        return 'Russian';
    }
  }

  static String _languageInstruction(String languageCode) {
    final lang = _languageName(languageCode);
    return '''
LANGUAGE REQUIREMENT (CRITICAL):
- Respond ONLY in $lang.
- Do not mix languages.
- All user-facing text fields (title, description, steps, tips, comments) must be in $lang.
''';
  }

  /// "None" in the requested language — for fields like injuries if empty.
  static String _none(String languageCode) {
    switch (normalizeLanguageCode(languageCode)) {
      case 'en': return 'none';
      case 'kk': return 'жоқ';
      default:   return 'нет';
    }
  }

  /// Inline instruction appended to each prompt field description.
  static String _inlineLanguageTag(String languageCode) {
    return 'in ${_languageName(languageCode)}';
  }

  static String _sanitizeForJsonPrompt(String value) {
    if (!value.contains('"')) return value;
    final buffer = StringBuffer();
    var useLeftQuote = true;
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      if (char == '"') {
        buffer.write(useLeftQuote ? '«' : '»');
        useLeftQuote = !useLeftQuote;
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// System prompt — defines AI behavior for all interactions.
  static String systemPrompt({String languageCode = 'ru'}) {
    return '''
You are an experienced AI fitness coach and rehabilitation specialist.
Your specialization: personalized adaptive workouts for people with health limitations.

${_languageInstruction(languageCode)}

SAFETY RULES:
1. User safety is priority #1. If unsure, choose the gentler option.
2. Respect all medical limitations and contraindications.
3. Give concrete, practical, realistic recommendations.
4. If JSON is requested, return ONLY valid JSON (no markdown fences, no explanations).
''';
  }

  /// Build workout generation prompt
  static String workoutGeneration({
    required UserProfile profile,
    required DailyCheckIn checkIn,
    required String workoutType,
    required List<Exercise> exercises,
    String? targetIntensity,
    String languageCode = 'ru',
  }) {
    final normalizedLanguageCode = normalizeLanguageCode(languageCode);
    final intensity = targetIntensity ?? checkIn.suggestedIntensity;
    final medical = profile.medicalProfile;
    final activityLabel = _activityLevelLabel(
      medical.activityLevel,
      normalizedLanguageCode,
    );
    final goalLabel = _goalLabel(profile.goals, normalizedLanguageCode);

    final injuriesText = medical.injuries.isNotEmpty
        ? medical.injuries.join(', ')
        : _none(normalizedLanguageCode);

    final contraindicationsText = medical.contraindications.isNotEmpty
        ? medical.contraindications.join(', ')
        : _none(normalizedLanguageCode);

    final workoutTypeLabel = _workoutTypeLabel(
      workoutType,
      normalizedLanguageCode,
    );

    final exercisesList = exercises
        .map((e) {
          final safeTitle = _sanitizeForJsonPrompt(e.title);
          final safeDescription = _sanitizeForJsonPrompt(e.description);
          return '- [${e.id}] $safeTitle: $safeDescription | '
              'Target muscles: ${e.targetMuscles.map((m) => TargetMuscles.labels[m] ?? m).join(", ")} | '
              'Difficulty: ${e.difficulty}';
        })
        .join('\n');

    return '''
${_languageInstruction(normalizedLanguageCode)}

Создай персонализированную тренировку типа "$workoutTypeLabel".

## ПРОФИЛЬ ПОЛЬЗОВАТЕЛЯ:
- Возраст: ${medical.age} лет
- Вес: ${medical.weight} кг
- Уровень активности: $activityLabel
- Цели: $goalLabel
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
6. В текстовых полях JSON не используй неэкранированные двойные кавычки ("); при необходимости используй «...» или экранирование \\"...\\".
7. Все текстовые поля в JSON должны быть ТОЛЬКО на ${_languageName(normalizedLanguageCode)}.

## ФОРМАТ ОТВЕТА (строго JSON, без markdown):
{
  "title": "Workout title in ${_languageName(normalizedLanguageCode)}",
  "description": "Short description in ${_languageName(normalizedLanguageCode)} (1-2 sentences)",
  "estimated_duration": число_минут,
  "warmup": [
    {
      "name": "Exercise name in ${_languageName(normalizedLanguageCode)}",
      "description": "Exercise description in ${_languageName(normalizedLanguageCode)}",
      "sets": 1,
      "reps": 10,
      "duration_seconds": 0,
      "rest_seconds": 15,
      "instructions": ["Step 1", "Step 2"],
      "difficulty": "easy",
      "target_muscles": ["muscle_1"],
      "doctor_comment": "Personalized safety comment in ${_languageName(normalizedLanguageCode)}"
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
    String languageCode = 'ru',
  }) {
    final normalizedLanguageCode = normalizeLanguageCode(languageCode);
    return '''
${_languageInstruction(normalizedLanguageCode)}

Пользователь испытывает боль в области "$painLocation" при выполнении "${currentExercise.name}".

Подбери ОДНО альтернативное упражнение:
1. Целевые мышцы: ${currentExercise.targetMuscles.join(', ')}
2. НЕ нагружает область боли ($painLocation)
3. Сложность: ${currentExercise.difficulty} или легче

ДОСТУПНЫЕ УПРАЖНЕНИЯ:
${safeExercises.map((e) => '- ${_sanitizeForJsonPrompt(e.title)}: ${_sanitizeForJsonPrompt(e.description)} | Мышцы: ${e.targetMuscles.join(", ")}').join('\n')}

Ответь ТОЛЬКО JSON. Не используй неэкранированные двойные кавычки внутри текстовых значений:
{
  "name": "Exercise name in ${_languageName(normalizedLanguageCode)}",
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
    String languageCode = 'ru',
  }) {
    final normalizedLanguageCode = normalizeLanguageCode(languageCode);
    final medical = profile.medicalProfile;
    final injuriesText = medical.injuries.isNotEmpty
        ? medical.injuries.join(', ')
        : _none(normalizedLanguageCode);

    return '''
${_languageInstruction(normalizedLanguageCode)}

PROFILE:
- Age: ${medical.age}
- Limitations: $injuriesText

EXERCISE: $exerciseName — $exerciseDescription

Explain in 2-3 sentences in plain language ${_inlineLanguageTag(normalizedLanguageCode)}:
1. Why this exercise is SAFE for this user
2. What effect it will have
3. What to pay attention to during execution
''';
  }

  /// Build quick recommendation prompt
  static String quickRecommendation(
    DailyCheckIn checkIn, {
    String languageCode = 'ru',
  }) {
    final normalizedLanguageCode = normalizeLanguageCode(languageCode);
    return '''
${_languageInstruction(normalizedLanguageCode)}

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
    String languageCode = 'ru',
  }) {
    final normalizedLanguageCode = normalizeLanguageCode(languageCode);
    final completionRate = (exercisesCompleted / totalExercises * 100).round();
    final painLocationsText = painLocations?.join(', ') ?? _none(normalizedLanguageCode);

    return '''
${_languageInstruction(normalizedLanguageCode)}

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

  static String _workoutTypeLabel(String workoutType, String languageCode) {
    final normalizedLanguageCode = normalizeLanguageCode(languageCode);
    switch (normalizedLanguageCode) {
      case 'en':
        switch (workoutType) {
          case WorkoutTypes.stretching:
            return 'Stretching';
          case WorkoutTypes.strength:
            return 'Strength';
          case WorkoutTypes.cardio:
            return 'Cardio';
          default:
            return 'Rehab / Therapeutic';
        }
      case 'kk':
        switch (workoutType) {
          case WorkoutTypes.stretching:
            return 'Созылу';
          case WorkoutTypes.strength:
            return 'Күштік';
          case WorkoutTypes.cardio:
            return 'Кардио';
          default:
            return 'ЕДШ';
        }
      default:
        return WorkoutTypes.labels[workoutType] ?? 'ЛФК';
    }
  }

  static String _activityLevelLabel(String rawValue, String languageCode) {
    final token = rawValue.trim().toLowerCase();

    final isHigh =
        token.contains('high') ||
        token.contains('высок') ||
        token.contains('жоғары');
    final isModerate =
        token.contains('moderate') ||
        token.contains('medium') ||
        token.contains('умерен') ||
        token.contains('орташа');

    switch (languageCode) {
      case 'en':
        if (isHigh) return 'high activity';
        if (isModerate) return 'moderate activity';
        return 'low activity';
      case 'kk':
        if (isHigh) return 'жоғары белсенділік';
        if (isModerate) return 'орташа белсенділік';
        return 'төмен белсенділік';
      default:
        if (isHigh) return 'высокая активность';
        if (isModerate) return 'умеренная активность';
        return 'низкая активность';
    }
  }

  static String _goalLabel(String rawValue, String languageCode) {
    final token = rawValue.trim().toLowerCase();

    switch (token) {
      case 'goal_relieve_back_pain':
        return _localizedGoalLabel(
          languageCode: languageCode,
          ru: 'избавиться от боли в спине',
          kk: 'арқа ауруынан құтылу',
          en: 'relieve back pain',
        );
      case 'goal_strengthen_core':
        return _localizedGoalLabel(
          languageCode: languageCode,
          ru: 'укрепить мышечный корсет',
          kk: 'бұлшықет корсетін қатайту',
          en: 'strengthen core muscles',
        );
      case 'goal_recover_from_injury':
        return _localizedGoalLabel(
          languageCode: languageCode,
          ru: 'восстановиться после травмы',
          kk: 'жарақаттан кейін қалпына келу',
          en: 'recover from injury',
        );
      case 'goal_improve_flexibility':
        return _localizedGoalLabel(
          languageCode: languageCode,
          ru: 'улучшить гибкость',
          kk: 'икемділікті жақсарту',
          en: 'improve flexibility',
        );
      case 'goal_maintain_general_tone':
        return _localizedGoalLabel(
          languageCode: languageCode,
          ru: 'поддержать общий тонус',
          kk: 'жалпы тонусты сақтау',
          en: 'maintain general tone',
        );
      default:
        return rawValue;
    }
  }

  static String _localizedGoalLabel({
    required String languageCode,
    required String ru,
    required String kk,
    required String en,
  }) {
    switch (languageCode) {
      case 'en':
        return en;
      case 'kk':
        return kk;
      default:
        return ru;
    }
  }
}
