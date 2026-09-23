import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Centralized ThemeData factory.
///
/// Only [light] exists today because Ahmad Rest & Cafe launches with a
/// single, fixed sage-green & white identity. A dark variant can be
/// added later by building a second `ThemeData` here and wiring it
/// through `ThemeMode` in a settings provider — no other file in the
/// app needs to change.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.primarySage,
      splashFactory: InkRipple.splashFactory,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primarySage,
        secondary: AppColors.primarySageLight,
        surface: AppColors.surfaceCard,
        error: AppColors.error,
        onPrimary: AppColors.textOnSage,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: AppTextStyles.h1,
        displayMedium: AppTextStyles.h2,
        displaySmall: AppTextStyles.h3,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.buttonPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primarySage,
          foregroundColor: AppColors.textOnSage,
          textStyle: AppTextStyles.buttonPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTextStyles.buttonSecondary,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceCardElevated,
        labelStyle: AppTextStyles.inputLabel,
        hintStyle: AppTextStyles.inputLabel,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primarySage, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      dividerColor: AppColors.divider,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primarySage,
        selectionColor: Color(0x336F9FA8),
        selectionHandleColor: AppColors.primarySage,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

/// Smooth cross-fade transition used on Android so page transitions feel
/// as cinematic as the iOS default, instead of Android's default slide.
class FadeThroughPageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeThroughPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
        child: child,
      ),
    );
  }
}
