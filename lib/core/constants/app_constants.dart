class AppConstants {
  AppConstants._();

  static const String appName = 'Ahmad Rest & Cafe';

  // SharedPreferences keys
  static const String prefLanguageCode = 'app_language_code';

  // Animation durations
  static const Duration splashDuration = Duration(milliseconds: 2600);
  static const Duration fastAnim = Duration(milliseconds: 220);
  static const Duration mediumAnim = Duration(milliseconds: 450);
  static const Duration slowAnim = Duration(milliseconds: 800);

  // Radii & spacing (base scale — multiply by MediaQuery scaling where needed)
  static const double radiusSmall = 12;
  static const double radiusMedium = 18;
  static const double radiusLarge = 28;

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;
}
