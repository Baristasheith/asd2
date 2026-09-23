import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

/// Secondary button with a light glassmorphism treatment: translucent
/// fill, soft blur, and a thin sage border. Used for social sign-in
/// options so the primary sage CTA (email flows) stays visually dominant.
class GlassOutlineButton extends StatefulWidget {
  final String label;
  final Widget leading;
  final VoidCallback? onPressed;

  const GlassOutlineButton({
    super.key,
    required this.label,
    required this.leading,
    required this.onPressed,
  });

  @override
  State<GlassOutlineButton> createState() => _GlassOutlineButtonState();
}

class _GlassOutlineButtonState extends State<GlassOutlineButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _scale = 0.97),
      onTapUp: disabled ? null : (_) => setState(() => _scale = 1.0),
      onTapCancel: disabled ? null : () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedOpacity(
        opacity: disabled ? 0.6 : 1,
        duration: AppConstants.fastAnim,
        child: AnimatedScale(
          scale: _scale,
          duration: AppConstants.fastAnim,
          curve: Curves.easeOut,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(color: AppColors.glassBorder, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.leading,
                    const SizedBox(width: AppConstants.spaceMd),
                    Flexible(
                      child: Text(
                        widget.label,
                        style: AppTextStyles.buttonSecondary,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
