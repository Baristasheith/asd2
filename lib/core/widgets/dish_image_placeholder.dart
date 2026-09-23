import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shows the dish's real photo when `imageUrl` is set (uploaded via the
/// Admin Panel), otherwise falls back to an elegant icon-on-gradient
/// placeholder. Every call site already passes a fixed size +
/// borderRadius, so dishes get real photos the moment an admin uploads
/// one — no layout changes needed anywhere.
class DishImagePlaceholder extends StatelessWidget {
  final IconData icon;
  final String? imageUrl;
  final double size;
  final double borderRadius;

  const DishImagePlaceholder({
    super.key,
    required this.icon,
    this.imageUrl,
    this.size = 64,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _iconPlaceholder(),
          errorWidget: (context, url, error) => _iconPlaceholder(),
        ),
      );
    }
    return _iconPlaceholder();
  }

  Widget _iconPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceCardElevated, AppColors.surfaceCard],
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: Icon(icon, color: AppColors.primarySage, size: size * 0.4),
    );
  }
}
