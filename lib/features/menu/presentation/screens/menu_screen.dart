import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/presentation/widgets/category_chip.dart';
import '../../data/menu_providers.dart';
import '../../domain/dish.dart';
import '../widgets/menu_item_card.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  DishCategory? _selectedCategory;
  String _query = '';

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spaceLg,
                  AppConstants.spaceMd,
                  AppConstants.spaceLg,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(l10n.navMenu, style: AppTextStyles.h2)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppConstants.spaceLg),
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  style: AppTextStyles.inputText,
                  decoration: InputDecoration(
                    hintText: l10n.searchMenuHint,
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  ),
                ),
              ),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
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
              const SizedBox(height: AppConstants.spaceMd),
              Expanded(
                child: dishesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primarySage)),
                  error: (err, _) => Center(child: Text(l10n.errorGeneric, style: AppTextStyles.bodyMedium)),
                  data: (allDishes) {
                    final results = allDishes
                        .where((d) => _selectedCategory == null || d.category == _selectedCategory)
                        .where((d) => d.name.toLowerCase().contains(_query.toLowerCase()))
                        .toList();

                    if (results.isEmpty) {
                      return Center(
                        child: Text(l10n.cartEmptySubtitle, style: AppTextStyles.bodyMedium),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.spaceLg,
                        0,
                        AppConstants.spaceLg,
                        AppConstants.spaceXxl,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppConstants.spaceMd,
                        crossAxisSpacing: AppConstants.spaceMd,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final dish = results[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 250 + (index % 6) * 60),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, child) => Opacity(opacity: v, child: child),
                          child: MenuItemCard(dish: dish),
                        );
                      },
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

