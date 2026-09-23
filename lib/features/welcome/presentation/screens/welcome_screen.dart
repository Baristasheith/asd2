import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_outline_button.dart';
import '../../../../core/widgets/gold_gradient_button.dart';
import '../../../auth/data/auth_error_mapper.dart';
import '../../../auth/data/auth_provider.dart';
import '../widgets/language_pill_button.dart';

/// Luxury welcome / landing screen. Every section (logo, headline,
/// subtitle, social buttons, divider, primary CTAs) fades and slides in
/// with its own staggered delay so the entrance feels choreographed
/// rather than instant — a hallmark of premium hospitality apps.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _stagger(double start, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  Widget _fadeSlide(Animation<double> anim, Widget child) {
    return FadeTransition(
      opacity: anim,
      child: AnimatedBuilder(
        animation: anim,
        builder: (context, c) => Transform.translate(
          offset: Offset(0, (1 - anim.value) * 18),
          child: c,
        ),
        child: child,
      ),
    );
  }

  Future<void> _handleGoogleSignIn(AppLocalizations l10n) async {
    setState(() => _isGoogleLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      if (!mounted) return;
      if (ref.read(authProvider) != null) context.go(AppRoutes.home);
    } on AuthException catch (e) {
      if (mounted) _showError(mapAuthErrorCode(l10n, e.code));
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleFacebookSignIn(AppLocalizations l10n) async {
    setState(() => _isFacebookLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithFacebook();
      if (!mounted) return;
      if (ref.read(authProvider) != null) context.go(AppRoutes.home);
    } on AuthException catch (e) {
      if (mounted) _showError(mapAuthErrorCode(l10n, e.code));
    } finally {
      if (mounted) setState(() => _isFacebookLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    final logoAnim = _stagger(0.0, 0.35);
    final titleAnim = _stagger(0.15, 0.5);
    final subtitleAnim = _stagger(0.25, 0.6);
    final socialAnim = _stagger(0.4, 0.75);
    final dividerAnim = _stagger(0.55, 0.85);
    final ctaAnim = _stagger(0.65, 1.0);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // Ambient glow, purely decorative.
              Positioned(
                top: -80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.spotlightGradient,
                    ),
                  ),
                ),
              ),

              // Language quick-switch, top corner (mirrors automatically
              // with Directionality since we use Align + AlignmentDirectional).
              Positioned(
                top: AppConstants.spaceMd,
                right: AppConstants.spaceLg,
                child: const LanguagePillButton(),
              ),

              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: size.height - MediaQuery.of(context).padding.vertical),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: isSmallScreen ? AppConstants.spaceXl : AppConstants.spaceXxl * 1.4),

                        // ---- Logo ----
                        _fadeSlide(
                          logoAnim,
                          Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
                                child: Text(
                                  'AHMAD REST & CAFE',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.subtitle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // ---- Headline ----
                        _fadeSlide(
                          titleAnim,
                          Text(
                            l10n.welcomeTitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h1,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spaceMd),

                        // ---- Subtitle / tagline ----
                        _fadeSlide(
                          subtitleAnim,
                          Text(
                            l10n.welcomeSubtitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.subtitle,
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? AppConstants.spaceXl : AppConstants.spaceXxl),

                        // ---- Social sign-in ----
                        _fadeSlide(
                          socialAnim,
                          Column(
                            children: [
                              GlassOutlineButton(
                                label: l10n.continueWithGoogle,
                                leading: _isGoogleLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primarySage),
                                      )
                                    : const _GLogoGlyph(),
                                onPressed: _isGoogleLoading || _isFacebookLoading ? null : () => _handleGoogleSignIn(l10n),
                              ),
                              const SizedBox(height: AppConstants.spaceMd),
                              GlassOutlineButton(
                                label: l10n.continueWithFacebook,
                                leading: _isFacebookLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primarySage),
                                      )
                                    : const Icon(Icons.facebook, color: AppColors.primarySage, size: 22),
                                onPressed: _isGoogleLoading || _isFacebookLoading ? null : () => _handleFacebookSignIn(l10n),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppConstants.spaceLg),

                        // ---- "or" divider ----
                        _fadeSlide(
                          dividerAnim,
                          Row(
                            children: [
                              const Expanded(child: Divider(color: AppColors.divider)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
                                child: Text(l10n.or, style: AppTextStyles.bodySmall),
                              ),
                              const Expanded(child: Divider(color: AppColors.divider)),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppConstants.spaceLg),

                        // ---- Primary CTAs ----
                        _fadeSlide(
                          ctaAnim,
                          Column(
                            children: [
                              GoldGradientButton(
                                label: l10n.createNewAccount,
                                onPressed: () => context.push(AppRoutes.signup),
                              ),
                              const SizedBox(height: AppConstants.spaceMd),
                              TextButton(
                                onPressed: () => context.push(AppRoutes.login),
                                child: Text(l10n.login, style: AppTextStyles.link),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? AppConstants.spaceLg : AppConstants.spaceXl),
                      ],
                    ),
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

/// Lightweight "G" glyph so we don't need an image asset for the
/// Google button placeholder — swap for the official asset before
/// shipping to comply with Google's branding guidelines.
class _GLogoGlyph extends StatelessWidget {
  const _GLogoGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceCard,
        border: Border.fromBorderSide(BorderSide(color: AppColors.divider)),
      ),
      child: const Text(
        'G',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      ),
    );
  }
}
