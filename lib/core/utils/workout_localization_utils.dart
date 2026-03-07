import '../../data/models/workout_model.dart';
import '../../gen/app_localizations.dart';

class WorkoutLocalizationUtils {
  const WorkoutLocalizationUtils._();

  static const Set<String> _genericWorkoutTitles = {
    'персональная тренировка',
    'жеке жаттығу',
    'personalized workout',
    'personal workout',
    'тренировка',
    'жаттығу',
    'workout',
  };

  static String localizedWorkoutType(AppLocalizations l10n, String type) {
    switch (type.toLowerCase()) {
      case WorkoutTypes.lfk:
        return l10n.workoutTypeLfk;
      case WorkoutTypes.stretching:
        return l10n.workoutTypeStretching;
      case WorkoutTypes.strength:
        return l10n.workoutTypeStrength;
      case WorkoutTypes.cardio:
        return l10n.workoutTypeCardio;
      default:
        return type;
    }
  }

  static String localizedWorkoutTitle({
    required AppLocalizations l10n,
    required String localeCode,
    required String type,
    required String rawTitle,
    String? sourceLanguageCode,
  }) {
    final trimmedTitle = rawTitle.trim();
    if (trimmedTitle.isEmpty || _isGenericWorkoutTitle(trimmedTitle)) {
      return _defaultWorkoutTitle(l10n, type);
    }

    if (sourceLanguageCode != null && sourceLanguageCode.trim().isNotEmpty) {
      final currentLocale = _normalizeLanguageCode(localeCode);
      final sourceLocale = _normalizeLanguageCode(sourceLanguageCode);
      if (sourceLocale != currentLocale) {
        return _defaultWorkoutTitle(l10n, type);
      }

      return trimmedTitle;
    }

    final detectedLocale = _detectLanguageFromTitle(trimmedTitle);
    final currentLocale = _normalizeLanguageCode(localeCode);
    if (detectedLocale != null && detectedLocale != currentLocale) {
      return _defaultWorkoutTitle(l10n, type);
    }

    return trimmedTitle;
  }

  static String localizedIntensity(AppLocalizations l10n, String rawIntensity) {
    final token = rawIntensity.trim().toLowerCase();

    if (_hasAny(token, const ['rest', 'отдых', 'демалыс'])) {
      return l10n.workoutIntensityRest;
    }
    if (_hasAny(token, const ['light', 'легк', 'жеңіл'])) {
      return l10n.workoutIntensityLight;
    }
    if (_hasAny(token, const ['moderate', 'умерен', 'орташа'])) {
      return l10n.workoutIntensityModerate;
    }
    if (_hasAny(token, const ['high', 'высок', 'жоғары'])) {
      return l10n.workoutIntensityHigh;
    }

    return rawIntensity;
  }

  static String localizedTimeAgo(AppLocalizations l10n, DateTime savedAt) {
    final diff = DateTime.now().difference(savedAt);

    if (diff.inMinutes < 60) {
      final minutes = diff.inMinutes <= 0 ? 1 : diff.inMinutes;
      return l10n.workoutTimeAgoMinutes(minutes);
    }

    if (diff.inHours < 24) {
      return l10n.workoutTimeAgoHours(diff.inHours);
    }

    return l10n.workoutTimeAgoDays(diff.inDays);
  }

  static String localizedExerciseFormat(
    AppLocalizations l10n,
    WorkoutExercise exercise,
  ) {
    if (exercise.durationSeconds > 0) {
      return '${exercise.sets} × ${exercise.durationSeconds} ${l10n.workoutSecondsUnitShort}';
    }

    return '${exercise.sets} × ${exercise.reps} ${l10n.workoutRepsUnitShort}';
  }

  static bool _hasAny(String value, List<String> candidates) {
    for (final candidate in candidates) {
      if (value.contains(candidate)) {
        return true;
      }
    }
    return false;
  }

  static bool _isGenericWorkoutTitle(String title) {
    final normalized = _normalizeText(title);
    return _genericWorkoutTitles.contains(normalized);
  }

  static String _defaultWorkoutTitle(AppLocalizations l10n, String type) {
    final localizedType = localizedWorkoutType(l10n, type);
    if (localizedType.trim().isEmpty) {
      return l10n.workoutPlayerTitle;
    }
    return localizedType;
  }

  static String _normalizeText(String value) {
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

  static String _normalizeLanguageCode(String languageCode) {
    final normalized = languageCode.trim().toLowerCase();
    if (normalized.startsWith('ru')) return 'ru';
    if (normalized.startsWith('en')) return 'en';
    return 'kk';
  }

  static String? _detectLanguageFromTitle(String title) {
    final value = title.trim();
    if (value.isEmpty) return null;

    final lower = value.toLowerCase();

    // Unique Kazakh Cyrillic letters.
    if (RegExp(r'[әіңғүұқөһ]').hasMatch(lower)) {
      return 'kk';
    }

    if (RegExp(r'[a-z]').hasMatch(lower)) {
      return 'en';
    }

    if (RegExp(r'[а-яё]').hasMatch(lower)) {
      return 'ru';
    }

    return null;
  }
}
