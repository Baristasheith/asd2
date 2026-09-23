import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_top_bar.dart';
import '../../../../core/widgets/dish_image_placeholder.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../menu/data/menu_providers.dart';
import '../../../menu/domain/dish.dart';
import 'admin_dish_form_screen.dart';

/// Lists every dish with edit/delete actions and a floating "add dish"
/// button. Gated behind `isAdminProvider` at the call site (Profile
/// screen only shows the entry point to admins) — but the real
/// enforcement is Firestore's security rules, not this UI check.
class AdminMenuScreen extends ConsumerWidget {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final dishesAsync = ref.watch(dishesStreamProvider);

    if (!isAdmin) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              const AuthTopBar(title: 'Admin Panel'),
              Expanded(
                child: Center(
                  child: Text('Not authorized.', style: AppTextStyles.bodyMedium),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primarySage,
        foregroundColor: AppColors.textOnSage,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdminDishFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              const AuthTopBar(title: 'Admin — Menu'),
              Expanded(
                child: dishesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primarySage)),
                  error: (err, _) => Center(child: Text('$err', style: AppTextStyles.bodyMedium)),
                  data: (dishes) => ListView.separated(
                    padding: const EdgeInsets.all(AppConstants.spaceLg),
                    itemCount: dishes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spaceMd),
                    itemBuilder: (context, index) => _AdminDishTile(dish: dishes[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminDishTile extends ConsumerWidget {
  final Dish dish;
  const _AdminDishTile({required this.dish});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLarge)),
        title: Text('Delete "${dish.name}"?', style: AppTextStyles.h3),
        content: Text('This cannot be undone.', style: AppTextStyles.bodyMedium),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: AppTextStyles.link.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(menuRepositoryProvider).deleteDish(dish.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          DishImagePlaceholder(icon: dish.icon, imageUrl: dish.imageUrl, size: 56),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(dish.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('\$${dish.price.toStringAsFixed(2)} · ${dish.category.name}', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primarySage, size: 20),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AdminDishFormScreen(existing: dish)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }
}
