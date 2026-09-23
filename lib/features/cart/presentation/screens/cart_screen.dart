import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/navigation/main_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/gold_gradient_button.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../orders/data/orders_provider.dart';
import '../../../orders/domain/order.dart';
import '../../data/cart_provider.dart';
import '../widgets/cart_item_tile.dart';

const _deliveryFee = 3.5;

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isCheckingOut = false;

  Future<void> _checkout(AppLocalizations l10n) async {
    final items = ref.read(cartItemsProvider);
    if (items.isEmpty) return;

    setState(() => _isCheckingOut = true);
    try {
      final subtotal = ref.read(cartSubtotalProvider);
      final orderItems = items.map((e) => OrderItem(dishName: e.key.name, quantity: e.value)).toList();

      await ref.read(ordersRepositoryProvider).createOrder(
            ref.read(authProvider)!.uid,
            items: orderItems,
            total: subtotal + _deliveryFee,
          );
      await ref.read(cartControllerProvider).clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderPlaced)),
      );
      MainShell.switchTab(context, 3);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = ref.watch(cartItemsProvider);
    final subtotal = ref.watch(cartSubtotalProvider);

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
                  children: [Expanded(child: Text(l10n.cartTitle, style: AppTextStyles.h2))],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? EmptyState(
                        icon: Icons.shopping_bag_outlined,
                        title: l10n.cartEmptyTitle,
                        subtitle: l10n.cartEmptySubtitle,
                        actionLabel: l10n.browseMenu,
                        onAction: () => MainShell.switchTab(context, 1),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppConstants.spaceLg),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spaceMd),
                        itemBuilder: (context, index) {
                          final entry = items[index];
                          return CartItemTile(dish: entry.key, quantity: entry.value);
                        },
                      ),
              ),
              if (items.isNotEmpty)
                _CheckoutBar(
                  subtotal: subtotal,
                  l10n: l10n,
                  isLoading: _isCheckingOut,
                  onCheckout: () => _checkout(l10n),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final double subtotal;
  final AppLocalizations l10n;
  final bool isLoading;
  final VoidCallback onCheckout;

  const _CheckoutBar({
    required this.subtotal,
    required this.l10n,
    required this.isLoading,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final total = subtotal + _deliveryFee;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppConstants.spaceLg, AppConstants.spaceLg, AppConstants.spaceLg, AppConstants.spaceLg),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PriceRow(label: l10n.subtotal, value: subtotal),
          const SizedBox(height: AppConstants.spaceXs),
          _PriceRow(label: l10n.deliveryFee, value: _deliveryFee),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppConstants.spaceSm),
            child: Divider(color: AppColors.divider),
          ),
          _PriceRow(label: l10n.total, value: total, emphasize: true),
          const SizedBox(height: AppConstants.spaceMd),
          GoldGradientButton(label: l10n.checkout, isLoading: isLoading, onPressed: onCheckout),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasize;
  const _PriceRow({required this.label, required this.value, this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.priceGold)
        : AppTextStyles.bodyMedium;
    return Row(
      children: [
        Expanded(child: Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis)),
        Text('\$${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}
