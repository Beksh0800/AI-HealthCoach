import 'package:flutter_test/flutter_test.dart';

import 'package:ai_health_coach/core/utils/exercise_localization_utils.dart';

void main() {
  group('ExerciseLocalizationUtils.normalizeExerciseName', () {
    test('removes bracketed technical id and keeps clean title', () {
      final resolved = ExerciseLocalizationUtils.normalizeExerciseName(
        rawName: 'Повороты шеи [lfk_neck_turns]',
      );

      expect(resolved.exerciseId, 'lfk_neck_turns');
      expect(resolved.cleanName, 'Повороты шеи');
    });

    test('humanizes technical id when user-facing title is missing', () {
      final resolved = ExerciseLocalizationUtils.normalizeExerciseName(
        rawName: '[lfk_shoulder_blade_squeeze]',
      );

      expect(resolved.exerciseId, 'lfk_shoulder_blade_squeeze');
      expect(resolved.cleanName, 'Shoulder Blade Squeeze');
    });
  });

  group('ExerciseLocalizationUtils.localizedExerciseName', () {
    test('returns localized title by exercise id and locale', () {
      final ru = ExerciseLocalizationUtils.localizedExerciseName(
        'ru',
        rawName: '[lfk_cat_cow]',
      );
      final kk = ExerciseLocalizationUtils.localizedExerciseName(
        'kk',
        rawName: '[lfk_cat_cow]',
      );
      final en = ExerciseLocalizationUtils.localizedExerciseName(
        'en',
        rawName: '[lfk_cat_cow]',
      );

      expect(ru, 'Кошка-Корова');
      expect(kk, 'Мысық-Сиыр');
      expect(en, 'Cat-Cow');
    });

    test('falls back to clean readable name for unknown exercise id', () {
      final displayName = ExerciseLocalizationUtils.localizedExerciseName(
        'ru',
        rawName: '[custom_balance_move]',
      );

      expect(displayName, 'Custom Balance Move');
    });
  });
}
