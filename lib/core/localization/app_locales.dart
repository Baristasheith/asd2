import 'package:flutter/material.dart';

/// A single supported language, paired with its display metadata.
/// This is the ONLY place new languages need to be registered besides
/// adding the matching `.arb` file in `lib/l10n/`.
class AppLocale {
  final Locale locale;
  final String nativeName;
  final String flagOrIcon;

  const AppLocale({
    required this.locale,
    required this.nativeName,
    required this.flagOrIcon,
  });
}

class AppLocales {
  AppLocales._();

  static const english = AppLocale(
    locale: Locale('en'),
    nativeName: 'English',
    flagOrIcon: '🇬🇧',
  );

  static const arabic = AppLocale(
    locale: Locale('ar'),
    nativeName: 'العربية',
    flagOrIcon: '🇸🇦',
  );

  // Kurdish (Kurmanji). Written natively in Latin script and read LTR;
  // per product spec it is grouped with Arabic as an RTL-tested locale so
  // its UI mirrors correctly if a Sorani/Arabic-script variant is added
  // later. See README "Kurdish directionality" note.
  static const kurdish = AppLocale(
    locale: Locale('ku'),
    nativeName: 'Kurdî',
    flagOrIcon: '☀️',
  );

  static const german = AppLocale(
    locale: Locale('de'),
    nativeName: 'Deutsch',
    flagOrIcon: '🇩🇪',
  );

  static const List<AppLocale> supported = [english, arabic, kurdish, german];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
    Locale('ku'),
    Locale('de'),
  ];

  /// Locale codes that should render Right-to-Left, per product spec.
  static const Set<String> rtlCodes = {'ar', 'ku'};

  static bool isRtl(String languageCode) => rtlCodes.contains(languageCode);

  static TextDirection directionOf(String languageCode) =>
      isRtl(languageCode) ? TextDirection.rtl : TextDirection.ltr;

  static AppLocale metaFor(String languageCode) {
    return supported.firstWhere(
      (l) => l.locale.languageCode == languageCode,
      orElse: () => english,
    );
  }
}
