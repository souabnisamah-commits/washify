import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'translations_map.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

// Singleton to access the current language code synchronously anywhere without ref
class LocaleManager {
  static String currentLang = 'fr';
}

class LocaleNotifier extends StateNotifier<Locale> {
  static const _langKey = 'app_lang';

  LocaleNotifier() : super(const Locale('fr')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_langKey) ?? 'fr';
    LocaleManager.currentLang = lang;
    state = Locale(lang);
  }

  Future<void> toggleLocale() async {
    final newLang = state.languageCode == 'fr' ? 'tn' : 'fr';
    LocaleManager.currentLang = newLang;
    state = Locale(newLang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, newLang);
  }
}

// Extension to easily translate strings anywhere
extension StringLocalization on String {
  String get tr {
    if (LocaleManager.currentLang == 'fr') return this;
    return translationsMap[this] ?? this;
  }
}
