class ExerciseNameResolution {
  const ExerciseNameResolution({
    required this.exerciseId,
    required this.cleanName,
  });

  final String? exerciseId;
  final String cleanName;
}

class ExerciseLocalizationUtils {
  ExerciseLocalizationUtils._();

  static const Map<String, Map<String, String>> _exerciseNameByLocale = {
    'ru': {
      'lfk_cat_cow': 'Кошка-Корова',
      'lfk_glute_bridge': 'Ягодичный мостик',
      'lfk_neck_turns': 'Повороты шеи',
      'lfk_bird_dog': 'Птица-Собака',
      'lfk_pelvic_tilt': 'Наклон таза лёжа',
      'lfk_knee_to_chest': 'Колено к груди',
      'lfk_dead_bug': 'Мёртвый жук',
      'lfk_supine_twist': 'Скручивание лёжа',
      'lfk_wall_angels': 'Ангел у стены',
      'lfk_chin_tuck': 'Втягивание подбородка',
      'lfk_shoulder_blade_squeeze': 'Сведение лопаток',
      'lfk_thoracic_rotation': 'Ротация грудного отдела',
    },
    'kk': {
      'lfk_cat_cow': 'Мысық-Сиыр',
      'lfk_glute_bridge': 'Жамбас көпірі',
      'lfk_neck_turns': 'Мойын бұрылыстары',
      'lfk_bird_dog': 'Құс-Ит',
      'lfk_pelvic_tilt': 'Жатып жамбас еңкейту',
      'lfk_knee_to_chest': 'Тізені кеудеге тарту',
      'lfk_dead_bug': 'Өлі қоңыз',
      'lfk_supine_twist': 'Жатып бұралу',
      'lfk_wall_angels': 'Қабырғадағы періште',
      'lfk_chin_tuck': 'Иекті ішке тарту',
      'lfk_shoulder_blade_squeeze': 'Жауырындарды жақындату',
      'lfk_thoracic_rotation': 'Кеуде бөлімін айналдыру',
    },
    'en': {
      'lfk_cat_cow': 'Cat-Cow',
      'lfk_glute_bridge': 'Glute Bridge',
      'lfk_neck_turns': 'Neck Turns',
      'lfk_bird_dog': 'Bird-Dog',
      'lfk_pelvic_tilt': 'Supine Pelvic Tilt',
      'lfk_knee_to_chest': 'Knee to Chest',
      'lfk_dead_bug': 'Dead Bug',
      'lfk_supine_twist': 'Supine Twist',
      'lfk_wall_angels': 'Wall Angels',
      'lfk_chin_tuck': 'Chin Tuck',
      'lfk_shoulder_blade_squeeze': 'Shoulder Blade Squeeze',
      'lfk_thoracic_rotation': 'Thoracic Rotation',
    },
  };

  static final RegExp _bracketedTechnicalTokenPattern = RegExp(
    r'\[([a-z0-9]+(?:_[a-z0-9]+)+)\]',
    caseSensitive: false,
  );
  static final RegExp _embeddedTechnicalTokenPattern = RegExp(
    r'\b([a-z0-9]+(?:_[a-z0-9]+)+)\b',
    caseSensitive: false,
  );

  static ExerciseNameResolution normalizeExerciseName({
    required String rawName,
    String? exerciseId,
  }) {
    final normalizedExerciseId =
        _normalizeTechnicalToken(exerciseId) ??
        _extractTechnicalExerciseId(rawName);
    final cleanedName = _cleanupTechnicalTokens(rawName, normalizedExerciseId);

    if (cleanedName.isNotEmpty) {
      return ExerciseNameResolution(
        exerciseId: normalizedExerciseId,
        cleanName: cleanedName,
      );
    }

    if (normalizedExerciseId != null) {
      return ExerciseNameResolution(
        exerciseId: normalizedExerciseId,
        cleanName: _humanizeTechnicalToken(normalizedExerciseId),
      );
    }

    final fallbackName = rawName.trim();
    return ExerciseNameResolution(exerciseId: null, cleanName: fallbackName);
  }

  static String localizedExerciseName(
    String localeCode, {
    required String rawName,
    String? exerciseId,
  }) {
    final resolved = normalizeExerciseName(
      rawName: rawName,
      exerciseId: exerciseId,
    );

    final localizedById = _localizedExerciseNameById(
      localeCode,
      resolved.exerciseId,
    );
    if (localizedById != null && localizedById.trim().isNotEmpty) {
      return localizedById;
    }

    return resolved.cleanName;
  }

  static String? _extractTechnicalExerciseId(String rawName) {
    final trimmed = rawName.trim();
    if (trimmed.isEmpty) return null;

    final bracketed = _bracketedTechnicalTokenPattern
        .firstMatch(trimmed)
        ?.group(1);
    final normalizedBracketed = _normalizeTechnicalToken(bracketed);
    if (normalizedBracketed != null) {
      return normalizedBracketed;
    }

    final embedded = _embeddedTechnicalTokenPattern
        .firstMatch(trimmed)
        ?.group(1);
    return _normalizeTechnicalToken(embedded);
  }

  static String? _normalizeTechnicalToken(String? value) {
    final candidate = value?.trim().toLowerCase();
    if (candidate == null || candidate.isEmpty) {
      return null;
    }

    final match = _bracketedTechnicalTokenPattern.firstMatch(candidate);
    final unwrapped = (match?.group(1) ?? candidate).trim();
    if (!_embeddedTechnicalTokenPattern.hasMatch(unwrapped)) {
      return null;
    }

    return unwrapped;
  }

  static String _cleanupTechnicalTokens(
    String rawName,
    String? normalizedExerciseId,
  ) {
    var cleaned = rawName.trim();
    if (cleaned.isEmpty) return '';

    cleaned = cleaned.replaceAll(_bracketedTechnicalTokenPattern, ' ');

    if (normalizedExerciseId != null) {
      final idPattern = RegExp(
        r'\b' + RegExp.escape(normalizedExerciseId) + r'\b',
        caseSensitive: false,
      );
      cleaned = cleaned.replaceAll(idPattern, ' ');
    }

    cleaned = cleaned
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[\s\-–—:|,;]+|[\s\-–—:|,;]+$'), '')
        .trim();

    final normalizedCleaned = _normalizeTechnicalToken(cleaned);
    if (normalizedCleaned != null) {
      return _humanizeTechnicalToken(normalizedCleaned);
    }

    return cleaned;
  }

  static String _humanizeTechnicalToken(String token) {
    final withoutPrefix = token
        .replaceFirst(RegExp(r'^lfk_', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^exercise_', caseSensitive: false), '');

    final words = withoutPrefix
        .split('_')
        .where((word) => word.trim().isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.length > 1 ? word.substring(1) : ''}',
        )
        .toList();

    if (words.isEmpty) {
      return token;
    }

    return words.join(' ');
  }

  static String? _localizedExerciseNameById(
    String localeCode,
    String? exerciseId,
  ) {
    if (exerciseId == null || exerciseId.trim().isEmpty) {
      return null;
    }

    final languageCode = _normalizeLanguageCode(localeCode);
    return _exerciseNameByLocale[languageCode]?[exerciseId];
  }

  static String _normalizeLanguageCode(String localeName) {
    final normalized = localeName.trim().toLowerCase();
    if (normalized.startsWith('en')) return 'en';
    if (normalized.startsWith('kk')) return 'kk';
    return 'ru';
  }
}
