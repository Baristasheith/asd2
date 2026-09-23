import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_locales.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'language_selector_sheet.dart';

/// Small pill button (e.g. "🌐 EN") shown in a corner of the Welcome
/// screen for a quick language switch without going into Settings.
class LanguagePillButton extends ConsumerWidget {
  const LanguagePillButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    final meta = AppLocales.metaFor(locale.languageCode);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => LanguageSelectorSheet.show(context),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language, size: 16, color: AppColors.primarySage),
              const SizedBox(width: AppConstants.spaceXs),
              Text(
                meta.locale.languageCode.toUpperCase(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
