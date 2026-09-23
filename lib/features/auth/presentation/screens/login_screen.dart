import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_top_bar.dart';
import '../../../../core/widgets/gold_gradient_button.dart';
import '../../../../core/widgets/luxury_text_field.dart';
import '../../data/auth_error_mapper.dart';
import '../../data/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate(AppLocalizations l10n) {
    setState(() {
      _emailError = _emailController.text.trim().isEmpty
          ? l10n.fieldRequired
          : (!_emailController.text.contains('@') ? l10n.invalidEmail : null);
      _passwordError = _passwordController.text.isEmpty
          ? l10n.fieldRequired
          : (_passwordController.text.length < 6 ? l10n.passwordTooShort : null);
    });
    return _emailError == null && _passwordError == null;
  }

  Future<void> _sendPasswordReset(AppLocalizations l10n) async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError = l10n.invalidEmail);
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.passwordResetSent)),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapAuthErrorCode(l10n, e.code)), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_validate(l10n)) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapAuthErrorCode(l10n, e.code)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              AuthTopBar(title: l10n.login),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spaceLg,
                    AppConstants.spaceLg,
                    AppConstants.spaceLg,
                    AppConstants.spaceXl,
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: AppConstants.slowAnim,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(offset: Offset(0, (1 - value) * 16), child: child),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.welcomeBack, style: AppTextStyles.h2, textAlign: TextAlign.center),
                        const SizedBox(height: AppConstants.spaceXs),
                        Text(
                          l10n.loginSubtitle,
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spaceXxl),
                        LuxuryTextField(
                          label: l10n.email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.alternate_email,
                          errorText: _emailError,
                        ),
                        const SizedBox(height: AppConstants.spaceMd),
                        LuxuryTextField(
                          label: l10n.password,
                          controller: _passwordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          errorText: _passwordError,
                        ),
                        const SizedBox(height: AppConstants.spaceSm),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            onPressed: () => _sendPasswordReset(l10n),
                            child: Text(l10n.forgotPassword, style: AppTextStyles.link),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spaceLg),
                        GoldGradientButton(
                          label: l10n.login,
                          isLoading: _isLoading,
                          onPressed: () => _submit(l10n),
                        ),
                        const SizedBox(height: AppConstants.spaceLg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                l10n.dontHaveAccount,
                                style: AppTextStyles.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.pushReplacement(AppRoutes.signup),
                              child: Text(l10n.signup, style: AppTextStyles.link),
                            ),
                          ],
                        ),
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

