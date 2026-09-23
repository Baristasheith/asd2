import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/dish_image_placeholder.dart';
import '../../../cart/data/cart_provider.dart';
import '../../../menu/data/menu_providers.dart';
import '../../../menu/domain/dish.dart';
import '../widgets/category_chip.dart';
import '../widgets/featured_dish_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DishCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // One-time bootstrap: populates Firestore's `dishes` collection from
    // the bundled seed catalog the very first time it's empty (fresh
    // Firebase project). No-op on every visit after that.
    Future.microtask(() => ref.read(menuRepositoryProvider).seedIfEmpty());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dishesAsync = ref.watch(dishesStreamProvider);

    final categories = <(String, DishCategory?)>[
      (l10n.allCategories, null),
      (l10n.starters, DishCategory.starters),
      (l10n.mainCourse, DishCategory.mainCourse),
      (l10n.desserts, DishCategory.desserts),
      (l10n.beverages, DishCategory.beverages),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: dishesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primarySage)),
            error: (err, _) => Center(
              child: Text(l10n.errorGeneric, style: AppTextStyles.bodyMedium),
            ),
            data: (allDishes) {
              final featured = allDishes.where((d) => d.isFeatured).toList();
              final popular = _selectedCategory == null
                  ? allDishes
                  : allDishes.where((d) => d.category == _selectedCategory).toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.spaceLg,
                      AppConstants.spaceLg,
                      AppConstants.spaceLg,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: AppConstants.mediumAnim,
                        builder: (context, v, child) => Opacity(opacity: v, child: child),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.helloUser, style: AppTextStyles.bodyMedium),
                            const SizedBox(height: AppConstants.spaceXs),
                            Text(
                              l10n.whatWouldYouLike,
                              style: AppTextStyles.h2,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ---- Featured Dishes rail ----
                  SliverPadding(
                    padding: const EdgeInsets.only(top: AppConstants.spaceXl),
                    sliver: SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
                        child: _SectionHeader(title: l10n.featuredDishes, actionLabel: l10n.seeAll),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 250,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg, vertical: AppConstants.spaceMd),
                        itemCount: featured.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppConstants.spaceMd),
                        itemBuilder: (context, index) {
                          final dish = featured[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(milliseconds: 350 + index * 90),
                            curve: Curves.easeOutCubic,
                            builder: (context, v, child) => Opacity(
                              opacity: v,
                              child: Transform.translate(offset: Offset((1 - v) * 24, 0), child: child),
                            ),
                            child: FeaturedDishCard(
                              dish: dish,
                              onTap: () => context.push(AppRoutes.dish(dish.id)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ---- Categories ----
                  SliverPadding(
                    padding: const EdgeInsets.only(top: AppConstants.spaceMd),
                    sliver: SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
                        child: Text(l10n.categories, style: AppTextStyles.h3),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 52,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg, vertical: AppConstants.spaceMd),
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppConstants.spaceSm),
                        itemBuilder: (context, index) {
                          final (label, category) = categories[index];
                          return CategoryChip(
                            label: label,
                            isSelected: _selectedCategory == category,
                            onTap: () => setState(() => _selectedCategory = category),
                          );
                        },
                      ),
                    ),
                  ),

                  // ---- Popular Now list ----
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.spaceLg,
                      AppConstants.spaceMd,
                      AppConstants.spaceLg,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text(l10n.popularNow, style: AppTextStyles.h3),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.spaceLg,
                      AppConstants.spaceMd,
                      AppConstants.spaceLg,
                      AppConstants.spaceXxl,
                    ),
                    sliver: SliverList.separated(
                      itemCount: popular.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spaceMd),
                      itemBuilder: (context, index) => _PopularDishTile(dish: popular[index]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  const _SectionHeader({required this.title, required this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: AppTextStyles.h3, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        TextButton(onPressed: () {}, child: Text(actionLabel, style: AppTextStyles.link)),
      ],
    );
  }
}

class _PopularDishTile extends ConsumerWidget {
  final Dish dish;
  const _PopularDishTile({required this.dish});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

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
        child: Row(
          children: [
            DishImagePlaceholder(icon: dish.icon, imageUrl: dish.imageUrl, size: 64),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(dish.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(dish.description, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppConstants.spaceXs),
                  Text('\$${dish.price.toStringAsFixed(2)}', style: AppTextStyles.price),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spaceSm),
            IconButton.filled(
              onPressed: () {
                ref.read(cartControllerProvider).add(dish.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.itemAddedToCart), duration: const Duration(milliseconds: 900)),
                );
              },
              style: IconButton.styleFrom(backgroundColor: AppColors.primarySage, foregroundColor: AppColors.textOnSage),
              icon: const Icon(Icons.add, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
