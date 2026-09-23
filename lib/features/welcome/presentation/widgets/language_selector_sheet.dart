import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_locales.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Shows the "Choose Language" bottom sheet. Call
/// `LanguageSelectorSheet.show(context)` from anywhere in the app
/// (Welcome screen's small globe button, or Settings later).
class LanguageSelectorSheet extends ConsumerWidget {
  const LanguageSelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const LanguageSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(languageProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceMd,
        AppConstants.spaceLg,
        AppConstants.spaceXl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppConstants.spaceLg),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text(l10n.chooseLanguage, style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            l10n.selectLanguageSubtitle,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spaceLg),
          ...List.generate(AppLocales.supported.length, (index) {
            final option = AppLocales.supported[index];
            final isSelected = option.locale.languageCode == currentLocale.languageCode;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + index * 80),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 12),
                  child: child,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                child: _LanguageTile(
                  option: option,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(languageProvider.notifier).setLocale(option.locale);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final AppLocale option;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: AnimatedContainer(
        duration: AppConstants.fastAnim,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd,
          vertical: AppConstants.spaceMd,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.glassFill : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primarySage : AppColors.divider,
            width: isSelected ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(option.flagOrIcon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Text(
                option.nativeName,
                style: AppTextStyles.bodyLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            AnimatedSwitcher(
              duration: AppConstants.fastAnim,
              child: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.primarySage, key: ValueKey('sel'))
                  : const SizedBox(width: 22, key: ValueKey('unsel')),
            ),
          ],
        ),
      ),
    );
  }
}
