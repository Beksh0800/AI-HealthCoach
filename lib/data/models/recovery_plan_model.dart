/// Model for post-workout recovery recommendations
class RecoveryPlan {
  /// Recommended rest duration (e.g., "24 часа", "48 часов")
  final String restDuration;

  /// Ordered recovery steps to follow
  final List<RecoveryStep> steps;

  /// Nutrition recommendation
  final String nutritionTip;

  /// Sleep recommendation
  final String sleepTip;

  const RecoveryPlan({
    required this.restDuration,
    required this.steps,
    required this.nutritionTip,
    required this.sleepTip,
  });

  factory RecoveryPlan.fromMap(Map<String, dynamic> map) {
    return RecoveryPlan(
      restDuration: map['rest_duration'] as String? ?? '24 часа',
      steps: (map['steps'] as List<dynamic>?)
              ?.map((s) => RecoveryStep.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      nutritionTip: map['nutrition_tip'] as String? ?? 'Пейте достаточно воды',
      sleepTip: map['sleep_tip'] as String? ?? 'Спите не менее 7-8 часов',
    );
  }

  Map<String, dynamic> toMap() => {
        'rest_duration': restDuration,
        'steps': steps.map((s) => s.toMap()).toList(),
        'nutrition_tip': nutritionTip,
        'sleep_tip': sleepTip,
      };

  /// Default recovery plan when AI is unavailable
  factory RecoveryPlan.defaultPlan({
    required String workoutType,
    required int durationMinutes,
    required int painReports,
  }) {
    final isIntense = durationMinutes > 30 || workoutType == 'Силовая';
    final hadPain = painReports > 0;

    return RecoveryPlan(
      restDuration: hadPain ? '48 часов' : (isIntense ? '24-48 часов' : '24 часа'),
      steps: [
        RecoveryStep(
          title: 'Горячий душ',
          description: 'Тёплый душ 10-15 минут для расслабления мышц и восстановления кровообращения',
          icon: '🚿',
          timing: 'Через 15-30 мин после тренировки',
        ),
        if (isIntense)
          const RecoveryStep(
            title: 'Контрастный душ',
            description: 'Чередуйте горячую и прохладную воду по 30 сек для улучшения циркуляции',
            icon: '🔄',
            timing: 'Альтернатива обычному душу',
          ),
        const RecoveryStep(
          title: 'Растяжка',
          description: 'Лёгкая растяжка 5-10 минут — фокус на задействованных мышцах',
          icon: '🧘',
          timing: 'Сразу после тренировки',
        ),
        if (hadPain)
          const RecoveryStep(
            title: 'Лёд на больные зоны',
            description: 'Приложите лёд на 15-20 минут к области, где была боль',
            icon: '🧊',
            timing: 'В первые 2 часа',
          ),
        const RecoveryStep(
          title: 'Питание',
          description: 'Белковая пища (творог, курица, яйца) + медленные углеводы в течение часа',
          icon: '🍽️',
          timing: 'В течение 30-60 мин',
        ),
        const RecoveryStep(
          title: 'Увлажнение',
          description: 'Выпейте 500-750 мл воды маленькими глотками',
          icon: '💧',
          timing: 'В течение 1-2 часов',
        ),
        if (isIntense)
          const RecoveryStep(
            title: 'Самомассаж',
            description: 'Лёгкий массаж или использование ролика для мышц',
            icon: '💆',
            timing: 'Вечером или перед сном',
          ),
        const RecoveryStep(
          title: 'Полноценный сон',
          description: 'Сон 7-9 часов — основное время восстановления мышц',
          icon: '😴',
          timing: 'Ложитесь до 23:00',
        ),
      ],
      nutritionTip: hadPain
          ? 'Добавьте противовоспалительные продукты: рыба, орехи, ягоды, зелёные овощи'
          : 'Белок (1.5-2г/кг веса) + вода (2-3 литра в день)',
      sleepTip: isIntense
          ? 'Спите 8-9 часов. Организму нужно больше времени после интенсивной нагрузки'
          : 'Спите не менее 7-8 часов для полного восстановления',
    );
  }
}

/// Individual recovery step with timing
class RecoveryStep {
  final String title;
  final String description;
  final String icon;
  final String? timing;

  const RecoveryStep({
    required this.title,
    required this.description,
    required this.icon,
    this.timing,
  });

  factory RecoveryStep.fromMap(Map<String, dynamic> map) {
    return RecoveryStep(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      icon: map['icon'] as String? ?? '✅',
      timing: map['timing'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'icon': icon,
        if (timing != null) 'timing': timing,
      };
}
