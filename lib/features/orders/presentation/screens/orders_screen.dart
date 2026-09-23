import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/navigation/main_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/orders_provider.dart';
import '../widgets/order_card.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

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
              Padding(
                padding: const EdgeInsets.fromLTRB(AppConstants.spaceLg, AppConstants.spaceMd, AppConstants.spaceLg, 0),
                child: Row(
                  children: [Expanded(child: Text(l10n.ordersTitle, style: AppTextStyles.h2))],
                ),
              ),
              Expanded(
                child: ordersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primarySage)),
                  error: (err, _) => Center(child: Text(l10n.errorGeneric, style: AppTextStyles.bodyMedium)),
                  data: (orders) {
                    if (orders.isEmpty) {
                      return EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: l10n.noOrdersTitle,
                        subtitle: l10n.noOrdersSubtitle,
                        actionLabel: l10n.browseMenu,
                        onAction: () => MainShell.switchTab(context, 1),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(AppConstants.spaceLg),
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spaceMd),
                      itemBuilder: (context, index) => TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 250 + index * 80),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, child) => Opacity(opacity: v, child: child),
                        child: OrderCard(order: orders[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
