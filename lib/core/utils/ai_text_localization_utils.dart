class AiTextLocalizationUtils {
  const AiTextLocalizationUtils._();

  static String normalizeLanguageCode(String languageCode) {
    final normalized = languageCode.trim().toLowerCase();
    if (normalized.startsWith('en')) return 'en';
    if (normalized.startsWith('kk')) return 'kk';
    return 'ru';
  }

  static bool shouldRequestLocalization({
    required String text,
    required String currentLocaleCode,
    String? sourceLanguageCode,
  }) {
    final normalizedLocale = normalizeLanguageCode(currentLocaleCode);
    final normalizedSource = _resolveSourceLanguage(
      text: text,
      sourceLanguageCode: sourceLanguageCode,
    );

    if (normalizedSource == null) {
      return false;
    }

    return normalizedSource != normalizedLocale;
  }

  static String? _resolveSourceLanguage({
    required String text,
    String? sourceLanguageCode,
  }) {
    final source = sourceLanguageCode?.trim();
    if (source != null && source.isNotEmpty) {
      return normalizeLanguageCode(source);
    }

    return detectLanguage(text);
  }

  static String? detectLanguage(String text) {
    final value = text.trim();
    if (value.isEmpty) return null;

    final lower = value.toLowerCase();
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
