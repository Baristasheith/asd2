import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/dish_image_placeholder.dart';
import '../../../../core/widgets/favorite_heart_button.dart';
import '../../../cart/data/cart_provider.dart';
import '../../../favorites/data/favorites_provider.dart';
import '../../../menu/domain/dish.dart';

/// Grid card for the Menu screen. Uses a fixed aspect-ratio image slot +
/// `Flexible`/`maxLines` text so long translated names (German runs
/// long) never overflow the card regardless of language. Tapping the
/// card (outside the heart/add controls) opens Dish Details.
class MenuItemCard extends ConsumerWidget {
  final Dish dish;
  const MenuItemCard({super.key, required this.dish});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isFavorite = ref.watch(favoritesProvider).maybeWhen(
          data: (ids) => ids.contains(dish.id),
          orElse: () => false,
        );

    return InkWell(
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      onTap: () => context.push(AppRoutes.dish(dish.id)),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: DishImagePlaceholder(icon: dish.icon, imageUrl: dish.imageUrl, size: 72),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: FavoriteHeartButton(
                    size: 26,
                    isFavorite: isFavorite,
                    onTap: () => ref.read(favoritesControllerProvider).toggle(dish.id),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              dish.name,
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              dish.description,
              style: AppTextStyles.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '\$${dish.price.toStringAsFixed(2)}',
                    style: AppTextStyles.price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    ref.read(cartControllerProvider).add(dish.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.itemAddedToCart), duration: const Duration(milliseconds: 900)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.primarySage, shape: BoxShape.circle),
                    child: const Icon(Icons.add, size: 16, color: AppColors.textOnSage),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
