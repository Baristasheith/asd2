import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Selectable pill used for category filters on Home and Menu.
/// `Flexible` + `TextOverflow.ellipsis` keep long German/Arabic category
/// names from ever overflowing the pill.
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.fastAnim,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.sageGradient : null,
          color: isSelected ? null : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.divider,
          ),
        ),
        constraints: const BoxConstraints(maxWidth: 160),
        child: Text(
          label,
          style: isSelected
              ? AppTextStyles.buttonPrimary.copyWith(fontSize: 13)
              : AppTextStyles.bodyMedium.copyWith(fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
