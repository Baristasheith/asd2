import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_locales.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_top_bar.dart';
import '../../../welcome/presentation/widgets/language_selector_sheet.dart';
import '../widgets/profile_menu_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(languageProvider);
    final localeMeta = AppLocales.metaFor(locale.languageCode);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              AuthTopBar(title: l10n.settingsTitle),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppConstants.spaceLg),
                  children: [
                    _SettingsSection(children: [
                      ProfileMenuTile(
                        icon: Icons.language,
                        label: l10n.language,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${localeMeta.flagOrIcon} ${localeMeta.nativeName}',
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(width: AppConstants.spaceSm),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                          ],
                        ),
                        onTap: () => LanguageSelectorSheet.show(context),
                      ),
                      const Divider(color: AppColors.divider, height: 1),
                      ProfileMenuTile(
                        icon: Icons.notifications_none,
                        label: l10n.notifications,
                        trailing: Switch(value: true, onChanged: (_) {}, activeColor: AppColors.primarySage),
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: AppConstants.spaceXl),
                    Center(
                      child: FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          final version = snapshot.data?.version ?? '1.0.0';
                          return Text(
                            '${l10n.appVersion}: $version',
                            style: AppTextStyles.caption,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final List<Widget> children;
  const _SettingsSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: children),
    );
  }
}
