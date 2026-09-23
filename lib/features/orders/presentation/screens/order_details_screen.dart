import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_top_bar.dart';
import '../../../../core/widgets/gold_gradient_button.dart';
import '../../data/orders_provider.dart';
import '../../domain/order.dart';
import '../widgets/order_status_timeline.dart';

/// Takes only the `orderId` and resolves it against the live orders
/// stream — the order list was already loaded on the Orders screen, so
/// this typically renders instantly from cache with no extra spinner.
class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ordersAsync = ref.watch(ordersStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              AuthTopBar(title: l10n.orderDetailsTitle),
              Expanded(
                child: ordersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primarySage)),
                  error: (err, _) => Center(child: Text(l10n.errorGeneric, style: AppTextStyles.bodyMedium)),
                  data: (orders) {
                    final matches = orders.where((o) => o.id == orderId);
                    final order = matches.isEmpty ? null : matches.first;
                    if (order == null) {
                      return Center(child: Text(l10n.errorGeneric, style: AppTextStyles.bodyMedium));
                    }
                    return _buildBody(context, l10n, order);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n, Order order) {
    final color = _statusColor(order.status);
    final formattedDate = DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_jm().format(order.date);

    return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spaceLg,
                    AppConstants.spaceMd,
                    AppConstants.spaceLg,
                    AppConstants.spaceXl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spaceLg),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.orderNumber(order.id),
                                    style: AppTextStyles.h3,
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
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spaceSm),
                            _InfoRow(label: l10n.dateLabel, value: formattedDate),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceLg),
                      OrderStatusTimeline(status: order.status),
                      const SizedBox(height: AppConstants.spaceLg),
                      Text(l10n.itemsLabel, style: AppTextStyles.h3),
                      const SizedBox(height: AppConstants.spaceMd),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < order.items.length; i++) ...[
                              if (i > 0) const Divider(color: AppColors.divider, height: 1),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.glassFill,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('${order.items[i].quantity}x', style: AppTextStyles.bodySmall),
                                    ),
                                    const SizedBox(width: AppConstants.spaceMd),
                                    Expanded(
                                      child: Text(
                                        order.items[i].dishName,
                                        style: AppTextStyles.bodyLarge,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceLg),
                      _InfoRow(
                        label: l10n.totalLabel,
                        value: '\$${order.total.toStringAsFixed(2)}',
                        emphasize: true,
                      ),
                      if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled) ...[
                        const SizedBox(height: AppConstants.spaceXl),
                        GoldGradientButton(label: l10n.reorder, onPressed: () {}),
                      ],
                    ],
                  ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;
  const _InfoRow({required this.label, required this.value, this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: emphasize
              ? AppTextStyles.h3.copyWith(color: AppColors.priceGold)
              : AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
