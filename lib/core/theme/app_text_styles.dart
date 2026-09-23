import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typography. Two font families give the "fine dining" feel:
/// - Playfair Display (serif) for display / headline moments
/// - Manrope (grotesque sans) for body text and UI, which also has
///   solid Arabic/Kurdish glyph coverage via Google Fonts fallback.
///
/// NOTE: `GoogleFonts` needs network access on first run to fetch font
/// files (or bundle them offline — see the "Offline fonts" note in the
/// README). For Arabic/Kurdish scripts we always fall back to the
/// platform's default font stack so RTL languages never render with
/// missing glyphs.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _display({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing ?? 0.2,
      height: height ?? 1.25,
    );
  }

  static TextStyle _body({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing ?? 0.1,
      height: height ?? 1.4,
    );
  }

  // ---- Display / Headlines (serif, luxury) ----
  static TextStyle splashLogo = _display(size: 34, weight: FontWeight.w700, letterSpacing: 4);
  static TextStyle splashSub = _body(size: 12, weight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 6);

  static TextStyle h1 = _display(size: 32, weight: FontWeight.w700);
  static TextStyle h2 = _display(size: 26, weight: FontWeight.w600);
  static TextStyle h3 = _display(size: 20, weight: FontWeight.w600);

  // ---- Body / UI (sans) ----
  static TextStyle subtitle = _body(size: 15, weight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 1.2);
  static TextStyle bodyLarge = _body(size: 16, weight: FontWeight.w400);
  static TextStyle bodyMedium = _body(size: 14, weight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle bodySmall = _body(size: 12, weight: FontWeight.w400, color: AppColors.textSecondary);

  static TextStyle buttonPrimary = _body(size: 15, weight: FontWeight.w700, color: AppColors.textOnSage, letterSpacing: 0.4);
  static TextStyle buttonSecondary = _body(size: 15, weight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.4);

  static TextStyle link = _body(size: 13, weight: FontWeight.w600, color: AppColors.primarySage);
  // Prices get the gold accent (not the teal `link` color) so money
  // reads as a distinct, deliberate "luxury" touch across every card.
  static TextStyle price = _body(size: 13, weight: FontWeight.w700, color: AppColors.priceGold);
  static TextStyle caption = _body(size: 11, weight: FontWeight.w400, color: AppColors.textDisabled);

  static TextStyle inputLabel = _body(size: 13, weight: FontWeight.w500, color: AppColors.textSecondary);
  static TextStyle inputText = _body(size: 15, weight: FontWeight.w500);
}
