import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_top_bar.dart';
import '../../../../core/widgets/avatar_picker.dart';
import '../../../../core/widgets/gold_gradient_button.dart';
import '../../../../core/widgets/luxury_text_field.dart';
import '../../data/auth_error_mapper.dart';
import '../../data/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  final Map<String, String?> _errors = {};
  File? _profileImage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validate(AppLocalizations l10n) {
    setState(() {
      _errors['fullName'] = _fullNameController.text.trim().isEmpty ? l10n.fieldRequired : null;
      _errors['username'] = _usernameController.text.trim().isEmpty ? l10n.fieldRequired : null;
      _errors['phone'] = _phoneController.text.trim().isEmpty ? l10n.fieldRequired : null;
      _errors['email'] = _emailController.text.trim().isEmpty
          ? l10n.fieldRequired
          : (!_emailController.text.contains('@') ? l10n.invalidEmail : null);
      _errors['password'] = _passwordController.text.isEmpty
          ? l10n.fieldRequired
          : (_passwordController.text.length < 6 ? l10n.passwordTooShort : null);
      _errors['confirmPassword'] = _confirmPasswordController.text != _passwordController.text
          ? l10n.passwordsDoNotMatch
          : null;
    });
    return _errors.values.every((e) => e == null);
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_validate(l10n)) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signUpWithEmail(
            fullName: _fullNameController.text.trim(),
            username: _usernameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            photoFile: _profileImage,
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
              AuthTopBar(title: l10n.signup),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spaceLg,
                    AppConstants.spaceMd,
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
                        Text(l10n.createAccountTitle, style: AppTextStyles.h2, textAlign: TextAlign.center),
                        const SizedBox(height: AppConstants.spaceXs),
                        Text(
                          l10n.createAccountSubtitle,
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spaceXl),

                        Center(
                          child: Column(
                            children: [
                              AvatarPicker(
                                initialImage: _profileImage,
                                onChanged: (file) => setState(() => _profileImage = file),
                              ),
                              const SizedBox(height: AppConstants.spaceSm),
                              Text(l10n.profilePicture, style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppConstants.spaceXl),

                        LuxuryTextField(
                          label: l10n.fullName,
                          controller: _fullNameController,
                          prefixIcon: Icons.person_outline,
                          errorText: _errors['fullName'],
                        ),
                        const SizedBox(height: AppConstants.spaceMd),
                        LuxuryTextField(
                          label: l10n.username,
                          controller: _usernameController,
                          prefixIcon: Icons.alternate_email,
                          errorText: _errors['username'],
                        ),
                        const SizedBox(height: AppConstants.spaceMd),
                        LuxuryTextField(
                          label: l10n.phoneNumber,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          errorText: _errors['phone'],
                        ),
                        const SizedBox(height: AppConstants.spaceMd),
                        LuxuryTextField(
                          label: l10n.email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail_outline,
                          errorText: _errors['email'],
                        ),
                        const SizedBox(height: AppConstants.spaceMd),
                        LuxuryTextField(
                          label: l10n.password,
                          controller: _passwordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          errorText: _errors['password'],
                        ),
                        const SizedBox(height: AppConstants.spaceMd),
                        LuxuryTextField(
                          label: l10n.confirmPassword,
                          controller: _confirmPasswordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          errorText: _errors['confirmPassword'],
                        ),
                        const SizedBox(height: AppConstants.spaceXl),

                        GoldGradientButton(
                          label: l10n.createAccount,
                          isLoading: _isLoading,
                          onPressed: () => _submit(l10n),
                        ),
                        const SizedBox(height: AppConstants.spaceLg),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                l10n.alreadyHaveAccount,
                                style: AppTextStyles.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.pushReplacement(AppRoutes.login),
                              child: Text(l10n.login, style: AppTextStyles.link),
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
