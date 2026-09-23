import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/order.dart';

/// Horizontal step tracker: Preparing → On the way → Delivered.
/// Cancelled orders render as a single red banner instead of a
/// timeline, since a cancellation isn't a step in the normal flow.
class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus status;
  const OrderStatusTimeline({super.key, required this.status});

  static const _steps = [OrderStatus.preparing, OrderStatus.onTheWay, OrderStatus.delivered];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: AppColors.error.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.error, size: 20),
            const SizedBox(width: AppConstants.spaceSm),
            Text(l10n.statusCancelled, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
          ],
        ),
      );
    }

    final currentIndex = _steps.indexOf(status);
    final labels = [l10n.statusPreparing, l10n.statusOnTheWay, l10n.statusDelivered];
    final icons = [Icons.soup_kitchen_outlined, Icons.delivery_dining_outlined, Icons.home_outlined];

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final segmentIndex = i ~/ 2;
          final isCompleted = segmentIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? AppColors.primarySage : AppColors.divider,
            ),
          );
        }

        final stepIndex = i ~/ 2;
        final isDone = stepIndex < currentIndex;
        final isCurrent = stepIndex == currentIndex;
        final isActive = isDone || isCurrent;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive ? AppColors.sageGradient : null,
                color: isActive ? null : AppColors.surfaceCardElevated,
                border: Border.all(color: isActive ? Colors.transparent : AppColors.divider),
              ),
              child: Icon(
                isDone ? Icons.check : icons[stepIndex],
                size: 18,
                color: isActive ? AppColors.textOnSage : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceXs),
            SizedBox(
              width: 64,
              child: Text(
                labels[stepIndex],
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: isActive ? AppColors.textPrimary : AppColors.textDisabled,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
