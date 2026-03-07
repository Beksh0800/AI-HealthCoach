class ProfileValueUtils {
  ProfileValueUtils._();

  static const String activityLow = 'low';
  static const String activityModerate = 'moderate';
  static const String activityHigh = 'high';

  static const List<String> activityCodes = [
    activityLow,
    activityModerate,
    activityHigh,
  ];

  static const String goalRelieveBackPain = 'goal_relieve_back_pain';
  static const String goalStrengthenCore = 'goal_strengthen_core';
  static const String goalRecoverFromInjury = 'goal_recover_from_injury';
  static const String goalImproveFlexibility = 'goal_improve_flexibility';
  static const String goalMaintainGeneralTone = 'goal_maintain_general_tone';

  static const List<String> goalCodes = [
    goalRelieveBackPain,
    goalStrengthenCore,
    goalRecoverFromInjury,
    goalImproveFlexibility,
    goalMaintainGeneralTone,
  ];

  static final Map<String, List<String>> _goalAliases = {
    goalRelieveBackPain: const [
      'избавиться от боли в спине',
      'арқа ауруынан құтылу',
      'relieve back pain',
    ],
    goalStrengthenCore: const [
      'укрепить мышечный корсет',
      'бұлшықет корсетін қатайту',
      'strengthen core muscles',
    ],
    goalRecoverFromInjury: const [
      'восстановиться после травмы',
      'жарақаттан кейін қалпына келу',
      'recover from injury',
    ],
    goalImproveFlexibility: const [
      'улучшить гибкость',
      'икемділікті жақсарту',
      'improve flexibility',
    ],
    goalMaintainGeneralTone: const [
      'поддержать общий тонус',
      'жалпы тонусты сақтау',
      'maintain general tone',
    ],
  };

  static String normalizeActivityCode(String rawValue) {
    final normalized = _normalizeToken(rawValue);

    if (normalized.isEmpty) {
      return activityModerate;
    }

    if (_containsAny(normalized, const [
      'high',
      'intense',
      'высок',
      'жоғары',
    ])) {
      return activityHigh;
    }

    if (_containsAny(normalized, const [
      'moderate',
      'medium',
      'умерен',
      'орташа',
    ])) {
      return activityModerate;
    }

    if (_containsAny(normalized, const [
      'low',
      'sedentary',
      'light',
      'сидяч',
      'легк',
      'төмен',
      'жеңіл',
      'отырықшы',
    ])) {
      return activityLow;
    }

    return activityModerate;
  }

  static String normalizeGoalValue(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) return '';

    final lowerCased = trimmed.toLowerCase();
    for (final code in goalCodes) {
      if (lowerCased == code) {
        return code;
      }
    }

    final normalized = _normalizeToken(trimmed);
    for (final entry in _goalAliases.entries) {
      for (final alias in entry.value) {
        if (normalized == _normalizeToken(alias)) {
          return entry.key;
        }
      }
    }

    return trimmed;
  }

  static String formatAgeByLocale(int age, String languageCode) {
    final normalizedLanguage = languageCode.trim().toLowerCase();
    if (normalizedLanguage.startsWith('ru')) {
      return '$age ${_russianAgeUnit(age)}';
    }
    if (normalizedLanguage.startsWith('kk')) {
      return '$age жас';
    }

    return age == 1 ? '1 year' : '$age years';
  }

  static String _russianAgeUnit(int age) {
    final mod10 = age % 10;
    final mod100 = age % 100;

    if (mod10 == 1 && mod100 != 11) {
      return 'год';
    }
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'года';
    }

    return 'лет';
  }

  static String _normalizeToken(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^a-zа-яёәіңғүұқөһ0-9]+', caseSensitive: false),
          ' ',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _containsAny(String value, List<String> aliases) {
    for (final alias in aliases) {
      if (value.contains(alias)) {
        return true;
      }
    }
    return false;
  }
}
