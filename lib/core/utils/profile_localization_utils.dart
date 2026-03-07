import '../../gen/app_localizations.dart';
import 'profile_value_utils.dart';

class ProfileLocalizationUtils {
  ProfileLocalizationUtils._();

  static String localizeActivity(AppLocalizations l10n, String rawValue) {
    switch (ProfileValueUtils.normalizeActivityCode(rawValue)) {
      case ProfileValueUtils.activityLow:
        return l10n.profileActivityLow;
      case ProfileValueUtils.activityHigh:
        return l10n.profileActivityHigh;
      default:
        return l10n.profileActivityModerate;
    }
  }

  static String localizeGoal(AppLocalizations l10n, String rawValue) {
    switch (ProfileValueUtils.normalizeGoalValue(rawValue)) {
      case ProfileValueUtils.goalRelieveBackPain:
        return l10n.goalRelieveBackPain;
      case ProfileValueUtils.goalStrengthenCore:
        return l10n.goalStrengthenCore;
      case ProfileValueUtils.goalRecoverFromInjury:
        return l10n.goalRecoverFromInjury;
      case ProfileValueUtils.goalImproveFlexibility:
        return l10n.goalImproveFlexibility;
      case ProfileValueUtils.goalMaintainGeneralTone:
        return l10n.goalMaintainGeneralTone;
      default:
        return rawValue;
    }
  }

  static String localizeInjury(AppLocalizations l10n, String rawValue) {
    switch (rawValue.trim()) {
      case 'Грыжа поясничного отдела (L4-L5, L5-S1)':
        return l10n.injuryHernia;
      case 'Протрузия межпозвонковых дисков':
        return l10n.injuryProtrusion;
      case 'Сколиоз':
        return l10n.injuryScoliosis;
      case 'Остеохондроз':
        return l10n.injuryOsteochondrosis;
      case 'Травма мениска':
        return l10n.injuryMeniscus;
      case 'Артроз коленного сустава':
        return l10n.injuryKneeArthrosis;
      case 'Артроз тазобедренного сустава':
        return l10n.injuryHipArthrosis;
      case 'Проблемы с плечевым суставом':
        return l10n.injuryShoulder;
      case 'Травма запястья':
        return l10n.injuryWrist;
      case 'Боли в шейном отделе':
        return l10n.injuryNeckPain;
      default:
        return rawValue;
    }
  }
}
