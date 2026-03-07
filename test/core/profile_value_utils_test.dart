import 'package:flutter_test/flutter_test.dart';

import 'package:ai_health_coach/core/utils/profile_value_utils.dart';

void main() {
  group('ProfileValueUtils.normalizeActivityCode', () {
    test('normalizes legacy russian values to low', () {
      expect(
        ProfileValueUtils.normalizeActivityCode('Сидячий образ жизни'),
        ProfileValueUtils.activityLow,
      );
    });

    test('normalizes kazakh moderate value', () {
      expect(
        ProfileValueUtils.normalizeActivityCode('Орташа белсенділік'),
        ProfileValueUtils.activityModerate,
      );
    });

    test('normalizes english high value', () {
      expect(
        ProfileValueUtils.normalizeActivityCode('High activity'),
        ProfileValueUtils.activityHigh,
      );
    });
  });

  group('ProfileValueUtils.normalizeGoalValue', () {
    test('maps localized russian goal to canonical code', () {
      expect(
        ProfileValueUtils.normalizeGoalValue('Избавиться от боли в спине'),
        ProfileValueUtils.goalRelieveBackPain,
      );
    });

    test('maps localized kazakh goal to canonical code', () {
      expect(
        ProfileValueUtils.normalizeGoalValue('Жарақаттан кейін қалпына келу'),
        ProfileValueUtils.goalRecoverFromInjury,
      );
    });

    test('keeps canonical goal code unchanged', () {
      expect(
        ProfileValueUtils.normalizeGoalValue(
          ProfileValueUtils.goalStrengthenCore,
        ),
        ProfileValueUtils.goalStrengthenCore,
      );
    });
  });

  group('ProfileValueUtils.formatAgeByLocale', () {
    test('formats russian age with correct pluralization', () {
      expect(ProfileValueUtils.formatAgeByLocale(25, 'ru'), '25 лет');
      expect(ProfileValueUtils.formatAgeByLocale(21, 'ru'), '21 год');
      expect(ProfileValueUtils.formatAgeByLocale(22, 'ru'), '22 года');
      expect(ProfileValueUtils.formatAgeByLocale(11, 'ru'), '11 лет');
    });

    test('formats kazakh age as жас', () {
      expect(ProfileValueUtils.formatAgeByLocale(25, 'kk'), '25 жас');
    });

    test('formats english age as year/years', () {
      expect(ProfileValueUtils.formatAgeByLocale(1, 'en'), '1 year');
      expect(ProfileValueUtils.formatAgeByLocale(25, 'en'), '25 years');
    });
  });
}
