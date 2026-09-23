import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/navigation/main_shell.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/data/auth_provider.dart';
import '../widgets/profile_menu_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLarge)),
        title: Text(l10n.confirmLogoutTitle, style: AppTextStyles.h3),
        content: Text(l10n.confirmLogoutMessage, style: AppTextStyles.bodyMedium),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: AppTextStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.logout, style: AppTextStyles.link.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).signOut();
      if (context.mounted) context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Falls back to the mock "Ahmad Ali" identity when no real sign-in
    // has happened yet (e.g. app just launched into this tab directly
    // during development/testing).
    final user = ref.watch(authProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final displayName = user?.fullName ?? 'Ahmad Ali';
    final displayEmail = user?.email.isNotEmpty == true ? user!.email : 'ahmad.ali@email.com';
    final photoUrl = user?.photoUrl;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            children: [
              Text(l10n.profileTitle, style: AppTextStyles.h2),
              const SizedBox(height: AppConstants.spaceXl),

              Center(
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.sageGradient),
                      child: CircleAvatar(
                        backgroundColor: AppColors.surfaceCardElevated,
                        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null
                            ? const Icon(Icons.person, size: 44, color: AppColors.primarySage)
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    Text(displayName, style: AppTextStyles.h3, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(displayEmail, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: AppConstants.spaceMd),
                    SizedBox(
                      width: 180,
                      child: OutlinedButton(
                        onPressed: () => context.push(AppRoutes.editProfile),
                        child: Text(l10n.editProfile),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spaceXl),
              _MenuSection(children: [
                ProfileMenuTile(
                  icon: Icons.receipt_long_outlined,
                  label: l10n.navOrders,
                  onTap: () => MainShell.switchTab(context, 3),
                ),
                const _TileDivider(),
                ProfileMenuTile(
                  icon: Icons.favorite_border,
                  label: l10n.myFavorites,
                  onTap: () => context.push(AppRoutes.favorites),
                ),
                const _TileDivider(),
                ProfileMenuTile(
                  icon: Icons.settings_outlined,
                  label: l10n.accountSettings,
                  onTap: () => context.push(AppRoutes.settings),
                ),
              ]),

              if (isAdmin) ...[
                const SizedBox(height: AppConstants.spaceMd),
                _MenuSection(children: [
                  ProfileMenuTile(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin Panel',
                    onTap: () => context.push(AppRoutes.admin),
                  ),
                ]),
              ],

              const SizedBox(height: AppConstants.spaceMd),
              _MenuSection(children: [
                ProfileMenuTile(
                  icon: Icons.help_outline,
                  label: l10n.helpSupport,
                  onTap: () {},
                ),
                const _TileDivider(),
                ProfileMenuTile(
                  icon: Icons.info_outline,
                  label: l10n.aboutUs,
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: AppConstants.spaceMd),
              _MenuSection(children: [
                ProfileMenuTile(
                  icon: Icons.logout,
                  label: l10n.logout,
                  iconColor: AppColors.error,
                  labelColor: AppColors.error,
                  trailing: const SizedBox.shrink(),
                  onTap: () => _confirmLogout(context, ref, l10n),
                ),
              ]),
              const SizedBox(height: AppConstants.spaceXl),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<Widget> children;
  const _MenuSection({required this.children});

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

class _TileDivider extends StatelessWidget {
  const _TileDivider();
  @override
  Widget build(BuildContext context) => const Divider(color: AppColors.divider, height: 1);
}
