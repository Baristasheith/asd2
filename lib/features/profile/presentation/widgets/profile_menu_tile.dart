import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A single tappable row in Profile/Settings (icon, label, chevron that
/// mirrors automatically under RTL via Directionality).
class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final Widget? trailing;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd, horizontal: AppConstants.spaceSm),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.primarySage, size: 22),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(color: labelColor ?? AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
