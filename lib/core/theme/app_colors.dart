import 'package:flutter/material.dart';

/// Central color palette for Ahmad Rest & Cafe.
/// Every color in the app MUST come from here — never hardcode a hex
/// value inside a widget.
///
/// Two accents by design: [primarySage] (a muted teal — kept the
/// "sage" token names from the previous palette to avoid touching 40+
/// call sites again) drives everyday interactive UI (buttons, links,
/// active nav, focus states), while [accentGold] is reserved for
/// deliberate "luxury" touches — prices, the wordmark, featured badges
/// — so it still reads as special rather than everywhere.
class AppColors {
  AppColors._();

  // ---- Brand core ----
  static const Color backgroundLight = Color(0xFFF3F8FA);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceCardElevated = Color(0xFFEAF3F4);

  // "Primary" teal — the app's main interactive color.
  static const Color primarySage = Color(0xFF6F9FA8);
  static const Color primarySageLight = Color(0xFF9CC0C7);
  static const Color primarySageDark = Color(0xFF4C7981);

  // "Luxury gold" — a deliberately sparing second accent.
  static const Color accentGold = Color(0xFFD6B56D);
  static const Color accentGoldLight = Color(0xFFE8D19A);
  static const Color accentGoldDark = Color(0xFFB0904F);
  // Gold-as-TEXT (prices, wordmark accents) uses the darker shade —
  // the lighter `accentGold` only has ~2:1 contrast on white, which
  // fails as foreground text; `accentGoldDark` reads clearly instead.
  static const Color priceGold = accentGoldDark;

  // ---- Text ----
  static const Color textPrimary = Color(0xFF243238);
  static const Color textSecondary = Color(0xFF5C6D72);
  // White reads poorly on the mid-tone teal (contrast ~2.9:1), so
  // button/badge labels use dark text instead — comfortably AA-legible
  // (~4.5:1) against `primarySage`.
  static const Color textOnSage = Color(0xFF243238);
  static const Color textOnGold = Color(0xFF243238);
  static const Color textDisabled = Color(0xFFAFC0C3);

  // ---- Semantic ----
  static const Color error = Color(0xFFB0524A);
  static const Color success = Color(0xFF4C8C5B);
  static const Color divider = Color(0xFFDCE7E9);

  // ---- Glassmorphism ----
  static const Color glassFill = Color(0x146F9FA8); // primary @ 8%
  static const Color glassBorder = Color(0x406F9FA8); // primary @ 25%

  // ---- Gradients ----
  static const LinearGradient sageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primarySageLight, primarySage, primarySageDark],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGoldLight, accentGold, accentGoldDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), backgroundLight, Color(0xFFEFF6F7)],
  );

  static const RadialGradient spotlightGradient = RadialGradient(
    center: Alignment(0, -0.4),
    radius: 1.2,
    colors: [Color(0x226F9FA8), Colors.transparent],
  );
}
