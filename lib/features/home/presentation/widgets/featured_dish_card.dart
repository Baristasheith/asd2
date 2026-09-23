import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/dish_image_placeholder.dart';
import '../../../../core/widgets/favorite_heart_button.dart';
import '../../../favorites/data/favorites_provider.dart';
import '../../../menu/domain/dish.dart';

/// Large horizontally-scrolling card used in the "Featured Dishes" rail
/// on Home. Subtle scale-on-tap for the "cards: subtle scale" animation
/// requirement. Tapping the card opens Dish Details; the heart toggles
/// favorite status independently.
class FeaturedDishCard extends ConsumerStatefulWidget {
  final Dish dish;
  final VoidCallback onTap;

  const FeaturedDishCard({super.key, required this.dish, required this.onTap});

  @override
  ConsumerState<FeaturedDishCard> createState() => _FeaturedDishCardState();
}

class _FeaturedDishCardState extends ConsumerState<FeaturedDishCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isFavorite = ref.watch(favoritesProvider).maybeWhen(
          data: (ids) => ids.contains(widget.dish.id),
          orElse: () => false,
        );

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: AppConstants.fastAnim,
        curve: Curves.easeOut,
        child: Container(
          width: 210,
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: DishImagePlaceholder(icon: widget.dish.icon, imageUrl: widget.dish.imageUrl, size: 96, borderRadius: 16),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: FavoriteHeartButton(
                      size: 28,
                      isFavorite: isFavorite,
                      onTap: () => ref.read(favoritesControllerProvider).toggle(widget.dish.id),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceMd),
              Text(
                widget.dish.name,
                style: AppTextStyles.h3.copyWith(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.spaceXs),
              Text(
                widget.dish.description,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Text(
                '\$${widget.dish.price.toStringAsFixed(2)}',
                style: AppTextStyles.price.copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
