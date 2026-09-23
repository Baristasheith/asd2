import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../localization/app_locales.dart';

/// Holds the currently active [Locale] for the whole app.
///
/// - Defaults to the device locale IF it's one of our 4 supported
///   languages, otherwise falls back to English.
/// - Changing it triggers an instant rebuild of every widget that reads
///   `AppLocalizations.of(context)` — no app restart, ever.
/// - Persists the user's explicit choice via SharedPreferences so it
///   survives app restarts.
class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(_deviceLocaleOrFallback()) {
    _loadSavedLocale();
  }

  static Locale _deviceLocaleOrFallback() {
    final deviceCode = PlatformDispatcher.instance.locale.languageCode;
    final isSupported = AppLocales.supportedLocales
        .any((l) => l.languageCode == deviceCode);
    return isSupported ? Locale(deviceCode) : AppLocales.english.locale;
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(AppConstants.prefLanguageCode);
    if (savedCode != null &&
        AppLocales.supportedLocales.any((l) => l.languageCode == savedCode)) {
      state = Locale(savedCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (state.languageCode == locale.languageCode) return;
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefLanguageCode, locale.languageCode);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>(
  (ref) => LanguageNotifier(),
);
