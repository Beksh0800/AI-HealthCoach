import 'package:flutter_test/flutter_test.dart';

import 'package:ai_health_coach/core/utils/workout_localization_utils.dart';
import 'package:ai_health_coach/data/models/workout_model.dart';
import 'package:ai_health_coach/gen/app_localizations_en.dart';
import 'package:ai_health_coach/gen/app_localizations_kk.dart';
import 'package:ai_health_coach/gen/app_localizations_ru.dart';

void main() {
  group('WorkoutLocalizationUtils.localizedWorkoutTitle', () {
    test('falls back to localized type for generic title', () {
      final l10nRu = AppLocalizationsRu();

      final title = WorkoutLocalizationUtils.localizedWorkoutTitle(
        l10n: l10nRu,
        localeCode: 'ru',
        type: WorkoutTypes.lfk,
        rawTitle: 'Personalized workout',
      );

      expect(title, l10nRu.workoutTypeLfk);
    });

    test('falls back to localized type when source language differs', () {
      final l10nKk = AppLocalizationsKk();

      final title = WorkoutLocalizationUtils.localizedWorkoutTitle(
        l10n: l10nKk,
        localeCode: 'kk',
        type: WorkoutTypes.stretching,
        rawTitle: 'Morning stretch',
        sourceLanguageCode: 'en',
      );

      expect(title, l10nKk.workoutTypeStretching);
    });

    test('keeps title when source language matches current locale', () {
      final l10nEn = AppLocalizationsEn();

      final title = WorkoutLocalizationUtils.localizedWorkoutTitle(
        l10n: l10nEn,
        localeCode: 'en',
        type: WorkoutTypes.strength,
        rawTitle: 'Core booster',
        sourceLanguageCode: 'en',
      );

      expect(title, 'Core booster');
    });

    test('detects old records language and applies fallback if needed', () {
      final l10nRu = AppLocalizationsRu();

      final title = WorkoutLocalizationUtils.localizedWorkoutTitle(
        l10n: l10nRu,
        localeCode: 'ru',
        type: WorkoutTypes.cardio,
        rawTitle: 'Morning cardio',
      );

      expect(title, l10nRu.workoutTypeCardio);
    });
  });
}
