import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Cinematic splash screen: the "AHMAD" wordmark fades & scales in,
/// followed a beat later by "REST & CAFE", a thin gold divider line
/// drawing itself outward, then the whole app navigates to Welcome.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _subFade;
  late final Animation<double> _lineWidth;
  late final Animation<double> _glowFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)),
    );
    _lineWidth = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.68, curve: Curves.easeOut),
    );
    _subFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
    );
    _glowFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(AppConstants.splashDuration, () {
      if (!mounted) return;
      // Firebase restores the session automatically on launch, so a
      // previously signed-in user skips Welcome/Login entirely and
      // lands straight back in the app — a real persistent session.
      final isSignedIn = FirebaseAuth.instance.currentUser != null;
      context.go(isSignedIn ? AppRoutes.home : AppRoutes.welcome);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Soft spotlight glow behind the logo.
                Opacity(
                  opacity: _glowFade.value,
                  child: Container(
                    width: 420,
                    height: 420,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.spotlightGradient,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: ShaderMask(
                          shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
                          child: Text(
                            'AHMAD',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.splashLogo.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    AnimatedBuilder(
                      animation: _lineWidth,
                      builder: (context, child) => ClipRect(
                        child: Align(
                          widthFactor: _lineWidth.value.clamp(0.0, 1.0),
                          child: Container(
                            height: 1.2,
                            width: 140,
                            decoration: BoxDecoration(gradient: AppColors.goldGradient),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    FadeTransition(
                      opacity: _subFade,
                      child: Text(
                        'REST & CAFE',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.splashSub,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
