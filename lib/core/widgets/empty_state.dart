import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shared empty-state layout (icon + title + subtitle + optional CTA),
/// used by Cart and Orders so both feel like one consistent product.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXl),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppConstants.slowAnim,
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => Opacity(
            opacity: v,
            child: Transform.scale(scale: 0.9 + (0.1 * v), child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceCard),
                child: Icon(icon, size: 40, color: AppColors.primarySage),
              ),
              const SizedBox(height: AppConstants.spaceLg),
              Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
              const SizedBox(height: AppConstants.spaceXs),
              Text(subtitle, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
              if (actionLabel != null) ...[
                const SizedBox(height: AppConstants.spaceLg),
                TextButton(onPressed: onAction, child: Text(actionLabel!, style: AppTextStyles.link)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
