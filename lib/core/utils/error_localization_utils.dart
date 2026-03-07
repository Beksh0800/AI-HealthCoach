import 'package:flutter/widgets.dart';

import '../../gen/app_localizations.dart';

class ErrorLocalizationUtils {
  const ErrorLocalizationUtils._();

  static String localize(
    BuildContext context,
    String? errorCode, {
    String? fallbackMessage,
  }) {
    final l10n = AppLocalizations.of(context);
    final normalizedCode = errorCode?.trim().toUpperCase() ?? '';

    switch (normalizedCode) {
      case 'NO_CONNECTION':
        return l10n.errorNoConnection;
      case 'TIMEOUT':
        return l10n.errorTimeout;
      case 'QUOTA_EXCEEDED':
        return l10n.errorAIQuota;
      case 'AI_UNAVAILABLE':
        return l10n.errorAIUnavailable;
      case 'NOT_CONFIGURED':
        return l10n.errorAINotConfigured;
      case 'EMPTY_RESPONSE':
        return l10n.errorAIEmpty;
      case 'PARSE_ERROR':
        return l10n.errorAIParse;
      case 'GENERATE_WORKOUT_FAILED':
        return l10n.errorGenerateWorkout;
      case 'CHECKIN_SAVE_FAILED':
        return l10n.errorSaveCheckin;
      case 'CHECKIN_LOAD_FAILED':
        return l10n.errorLoadCheckin;
      case 'PROFILE_SAVE_FAILED':
        return l10n.errorSaveProfile;
      case 'PROFILE_LOAD_FAILED':
      case 'PROFILE_SYNC_FAILED':
        return l10n.errorLoadProfile;
      case 'AUTH_STATUS_FAILED':
        return l10n.errorAuthStatus;
      case 'AUTH_SIGNIN_FAILED':
        return l10n.errorAuthSignIn;
      case 'AUTH_SIGNUP_FAILED':
        return l10n.errorAuthSignUp;
      case 'PERMISSION_DENIED':
        return l10n.errorPermissionDenied;
      case 'TOO_MANY_REQUESTS':
        return l10n.errorTooManyRequests;
      case 'INVALID_CREDENTIALS':
        return l10n.errorInvalidCredentials;
      case 'EMAIL_IN_USE':
        return l10n.errorEmailInUse;
      case 'WEAK_PASSWORD':
        return l10n.errorWeakPassword;
      case 'NOT_AUTHENTICATED':
        return l10n.errorNotAuthenticated;
      default:
        if (fallbackMessage != null && fallbackMessage.trim().isNotEmpty) {
          return fallbackMessage;
        }
        return l10n.errorGeneral;
    }
  }
}
