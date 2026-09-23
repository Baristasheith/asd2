import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shared top bar for auth screens: a back button that mirrors correctly
/// under RTL/LTR via `Icons.arrow_back_ios_new` (auto-flips with
/// Directionality) plus a perfectly centered title regardless of
/// translated string length.
class AuthTopBar extends StatelessWidget {
  final String title;
  const AuthTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceSm, vertical: AppConstants.spaceSm),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop() : null,
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 48), // balances the back button for true centering
        ],
      ),
    );
  }
}
