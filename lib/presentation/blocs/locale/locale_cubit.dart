import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('kk'));

  static const _keyLocaleCode = 'app_locale_code';

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyLocaleCode);
    if (code == null || code.isEmpty) {
      emit(const Locale('kk'));
      return;
    }

    emit(Locale(code));
  }

  Future<void> changeLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocaleCode, languageCode);
    emit(Locale(languageCode));
  }
}
