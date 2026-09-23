import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/dish_image_placeholder.dart';
import '../../../../core/widgets/favorite_heart_button.dart';
import '../../../../core/widgets/gold_gradient_button.dart';
import '../../../cart/data/cart_provider.dart';
import '../../../favorites/data/favorites_provider.dart';
import '../../data/menu_providers.dart';
import '../../domain/dish.dart';

/// Takes only the dish `id` (not the full `Dish`) because the dish list
/// now streams live from Firestore — looking it up by id here means the
/// details screen always reflects the latest price/description, even if
/// it changed after the person navigated here.
class DishDetailsScreen extends ConsumerStatefulWidget {
  final String dishId;
  const DishDetailsScreen({super.key, required this.dishId});

  @override
  ConsumerState<DishDetailsScreen> createState() => _DishDetailsScreenState();
}

class _DishDetailsScreenState extends ConsumerState<DishDetailsScreen> with SingleTickerProviderStateMixin {
  int _quantity = 1;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppConstants.slowAnim)..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dishesAsync = ref.watch(dishesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: dishesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primarySage)),
            error: (err, _) => Center(child: Text(l10n.errorGeneric, style: AppTextStyles.bodyMedium)),
            data: (dishes) {
              final matches = dishes.where((d) => d.id == widget.dishId);
              final dish = matches.isEmpty ? null : matches.first;
              if (dish == null) {
                return Center(child: Text(l10n.errorGeneric, style: AppTextStyles.bodyMedium));
              }
              return _buildBody(context, l10n, dish);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n, Dish dish) {
    final isFavorite = ref.watch(favoritesProvider).maybeWhen(
          data: (ids) => ids.contains(dish.id),
          orElse: () => false,
        );
    final fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceSm, vertical: AppConstants.spaceSm),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
              ),
              const Spacer(),
              FavoriteHeartButton(
                isFavorite: isFavorite,
                onTap: () {
                  ref.read(favoritesControllerProvider).toggle(dish.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isFavorite ? l10n.removedFromFavorites : l10n.addedToFavorites),
                      duration: const Duration(milliseconds: 900),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceLg,
              AppConstants.spaceMd,
              AppConstants.spaceLg,
              AppConstants.spaceXl,
            ),
            child: FadeTransition(
              opacity: fade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: DishImagePlaceholder(icon: dish.icon, imageUrl: dish.imageUrl, size: 180, borderRadius: 28),
                  ),
                  const SizedBox(height: AppConstants.spaceXl),
                  Text(dish.name, style: AppTextStyles.h2),
                  const SizedBox(height: AppConstants.spaceXs),
                  Text(
                    '\$${dish.price.toStringAsFixed(2)}',
                    style: AppTextStyles.h3.copyWith(color: AppColors.priceGold, fontSize: 20),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                  Text(l10n.descriptionLabel, style: AppTextStyles.inputLabel),
                  const SizedBox(height: AppConstants.spaceXs),
                  Text(dish.description, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: AppConstants.spaceXl),
                  Row(
                    children: [
                      Text(l10n.quantity, style: AppTextStyles.inputLabel),
                      const Spacer(),
                      _QuantityControl(
                        quantity: _quantity,
                        onIncrement: () => setState(() => _quantity++),
                        onDecrement: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppConstants.spaceLg, 0, AppConstants.spaceLg, AppConstants.spaceLg),
          child: GoldGradientButton(
            label: '${l10n.addToCart} · \$${(dish.price * _quantity).toStringAsFixed(2)}',
            onPressed: () {
              for (var i = 0; i < _quantity; i++) {
                ref.read(cartControllerProvider).add(dish.id);
              }
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityControl({required this.quantity, required this.onIncrement, required this.onDecrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: onDecrement, icon: const Icon(Icons.remove, size: 18, color: AppColors.primarySage)),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(onPressed: onIncrement, icon: const Icon(Icons.add, size: 18, color: AppColors.primarySage)),
        ],
      ),
    );
  }
}
