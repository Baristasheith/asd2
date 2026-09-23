import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/cart/data/cart_provider.dart';

class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavItemData({required this.icon, required this.activeIcon, required this.label});
}

/// Custom bottom navigation bar matching the luxury identity: dark
/// glass background, sage highlight for the active tab, and a small
/// animated indicator pill that slides between icons.
class LuxuryBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final List<NavItemData> items;
  final ValueChanged<int> onTap;

  const LuxuryBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;
              // Index 2 is the Cart tab in the shell's item order.
              final showBadge = index == 2 && cartCount > 0;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: AppConstants.fastAnim,
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.glassFill : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected ? AppColors.primarySage : AppColors.textSecondary,
                              size: 22,
                            ),
                            if (showBadge)
                              Positioned(
                                top: -4,
                                right: -6,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(color: AppColors.primarySage, shape: BoxShape.circle),
                                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                  child: Text(
                                    '$cartCount',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textOnSage),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected ? AppColors.primarySage : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
