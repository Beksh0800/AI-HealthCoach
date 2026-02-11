/// Application constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'AI-HealthCoach';
  static const String appVersion = '1.0.0';

  // API Endpoints (for future use)
  static const String geminiModel = 'gemini-1.5-flash';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String exercisesCollection = 'exercises_library';
  static const String historyCollection = 'history';

  // Activity Levels
  static const List<String> activityLevels = [
    'Сидячий образ жизни',
    'Легкая активность',
    'Умеренная активность',
    'Высокая активность',
  ];

  // Common Injuries/Diagnoses
  static const List<String> commonInjuries = [
    'Грыжа поясничного отдела (L4-L5, L5-S1)',
    'Протрузия межпозвонковых дисков',
    'Сколиоз',
    'Остеохондроз',
    'Травма мениска',
    'Артроз коленного сустава',
    'Артроз тазобедренного сустава',
    'Проблемы с плечевым суставом',
    'Травма запястья',
    'Боли в шейном отделе',
  ];

  // Contraindications mapping
  static const Map<String, List<String>> contraindicationsMap = {
    'Грыжа поясничного отдела (L4-L5, L5-S1)': [
      'Осевая нагрузка',
      'Скручивания',
      'Прыжки',
      'Наклоны с весом',
    ],
    'Протрузия межпозвонковых дисков': [
      'Осевая нагрузка',
      'Резкие движения',
      'Прыжки',
    ],
    'Сколиоз': [
      'Асимметричные упражнения с весом',
      'Прыжки с приземлением',
    ],
    'Травма мениска': [
      'Глубокие приседания',
      'Прыжки',
      'Бег',
      'Выпады с большой амплитудой',
    ],
    'Артроз коленного сустава': [
      'Прыжки',
      'Бег',
      'Глубокие приседания',
    ],
  };

  // Pain levels
  static const int painThresholdForLightWorkout = 4;
  static const int painThresholdForNoWorkout = 7;
}
