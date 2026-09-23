import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Small circular heart toggle with a soft pop animation, reused on
/// dish cards and the dish details screen.
class FavoriteHeartButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final double size;

  const FavoriteHeartButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(color: AppColors.glassFill, shape: BoxShape.circle),
        child: AnimatedSwitcher(
          duration: AppConstants.fastAnim,
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(isFavorite),
            color: isFavorite ? AppColors.error : AppColors.textSecondary,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
