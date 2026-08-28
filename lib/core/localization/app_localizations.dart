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

  static bool get isRtl => currentLang == 'ar' || currentLang == 'tn';
}

class LocaleNotifier extends StateNotifier<Locale> {
  static const _langKey = 'app_lang';

  LocaleNotifier() : super(const Locale('fr', 'FR')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_langKey) ?? 'fr';
    LocaleManager.currentLang = lang;
    if (lang == 'ar' || lang == 'tn') {
      state = const Locale('ar', 'TN');
    } else {
      state = const Locale('fr', 'FR');
    }
  }

  Future<void> toggleLocale() async {
    final isFr = state.languageCode == 'fr';
    final newLangCode = isFr ? 'ar' : 'fr';
    LocaleManager.currentLang = newLangCode;
    
    if (isFr) {
      state = const Locale('ar', 'TN');
    } else {
      state = const Locale('fr', 'FR');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, newLangCode);
  }
}

// Extension to easily translate strings anywhere
extension StringLocalization on String {
  String get tr {
    if (LocaleManager.currentLang == 'fr') return this;
    return translationsMap[this] ?? this;
  }
}
