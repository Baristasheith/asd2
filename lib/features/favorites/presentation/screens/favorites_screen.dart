import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_top_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/favorites_provider.dart';
import '../../../menu/presentation/widgets/menu_item_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dishes = ref.watch(favoriteDishesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              AuthTopBar(title: l10n.myFavorites),
              Expanded(
                child: dishes.isEmpty
                    ? EmptyState(
                        icon: Icons.favorite_border,
                        title: l10n.noFavoritesTitle,
                        subtitle: l10n.noFavoritesSubtitle,
                        actionLabel: l10n.browseMenu,
                        onAction: () => context.go(AppRoutes.menu),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppConstants.spaceLg,
                          AppConstants.spaceMd,
                          AppConstants.spaceLg,
                          AppConstants.spaceXxl,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppConstants.spaceMd,
                          crossAxisSpacing: AppConstants.spaceMd,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: dishes.length,
                        itemBuilder: (context, index) => MenuItemCard(dish: dishes[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
