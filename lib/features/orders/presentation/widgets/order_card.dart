import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  const OrderCard({super.key, required this.order});

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.preparing:
        return AppColors.primarySage;
      case OrderStatus.onTheWay:
        return AppColors.primarySageLight;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String _statusLabel(AppLocalizations l10n, OrderStatus status) {
    switch (status) {
      case OrderStatus.preparing:
        return l10n.statusPreparing;
      case OrderStatus.onTheWay:
        return l10n.statusOnTheWay;
      case OrderStatus.delivered:
        return l10n.statusDelivered;
      case OrderStatus.cancelled:
        return l10n.statusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final itemsSummary = order.items.map((e) => '${e.quantity}x ${e.dishName}').join(' · ');
    final color = _statusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        onTap: () => context.push(AppRoutes.orderDetails(order.id)),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.orderNumber(order.id),
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  _statusLabel(l10n, order.status),
                  style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            itemsSummary,
            style: AppTextStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Row(
            children: [
              Expanded(
                child: Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: AppTextStyles.price,
                ),
              ),
              if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled)
                TextButton(onPressed: () {}, child: Text(l10n.reorder, style: AppTextStyles.link)),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
