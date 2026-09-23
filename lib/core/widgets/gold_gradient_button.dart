import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

/// Primary CTA button with the signature sage gradient and a subtle
/// scale-down press animation. Reused everywhere so the "premium feel"
/// stays identical across every screen and language.
///
/// (Class name kept as `GoldGradientButton` from the original dark/gold
/// identity to avoid a risky rename across every import site — it now
/// renders the sage gradient, not gold.)
class GoldGradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  const GoldGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  State<GoldGradientButton> createState() => _GoldGradientButtonState();
}

class _GoldGradientButtonState extends State<GoldGradientButton> {
  double _scale = 1.0;

  void _setPressed(bool pressed) {
    setState(() => _scale = pressed ? 0.97 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => _setPressed(true),
      onTapUp: disabled ? null : (_) => _setPressed(false),
      onTapCancel: disabled ? null : () => _setPressed(false),
      onTap: disabled ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: AppConstants.fastAnim,
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: disabled && widget.isLoading ? 0.85 : (disabled ? 0.5 : 1),
          duration: AppConstants.fastAnim,
          child: Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.sageGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySage.withOpacity(0.20),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(AppColors.textOnSage),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 18, color: AppColors.textOnSage),
                          const SizedBox(width: AppConstants.spaceSm),
                        ],
                        Flexible(
                          child: Text(
                            widget.label,
                            style: AppTextStyles.buttonPrimary,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
