import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_top_bar.dart';
import '../../../../core/widgets/avatar_picker.dart';
import '../../../../core/widgets/gold_gradient_button.dart';
import '../../../../core/widgets/luxury_text_field.dart';
import '../../../auth/data/auth_error_mapper.dart';
import '../../../auth/data/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  bool _isSaving = false;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    // Pre-fill from the real signed-in user when one exists; otherwise
    // fall back to the same mock identity shown on Profile.
    final user = ref.read(authProvider);
    _fullNameController = TextEditingController(text: user?.fullName ?? 'Ahmad Ali');
    _usernameController = TextEditingController(
      text: user?.username ?? (user?.fullName ?? 'ahmad.ali').toLowerCase().replaceAll(' ', '.'),
    );
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(
      text: user?.email.isNotEmpty == true ? user!.email : 'ahmad.ali@email.com',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    setState(() => _isSaving = true);
    try {
      // Note: email is intentionally NOT updated here — changing a
      // Firebase Auth email requires a fresh re-authentication step
      // (`updateEmail`/`verifyBeforeUpdateEmail`) which is a separate,
      // more sensitive flow than the rest of this form.
      await ref.read(authProvider.notifier).updateProfile(
            fullName: _fullNameController.text.trim(),
            username: _usernameController.text.trim(),
            phone: _phoneController.text.trim(),
            newPhotoFile: _profileImage,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileUpdated)),
      );
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapAuthErrorCode(l10n, e.code)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showChangeEmailDialog(AppLocalizations l10n) async {
    final user = ref.read(authProvider);
    if (user == null || user.provider != AuthProvider.email) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emailChangeNotAvailable)),
      );
      return;
    }

    final newEmailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLarge)),
          title: Text(l10n.changeEmail),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LuxuryTextField(
                label: l10n.newEmail,
                controller: newEmailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppConstants.spaceMd),
              LuxuryTextField(
                label: l10n.currentPassword,
                controller: passwordController,
                obscureText: true,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setDialogState(() => isSubmitting = true);
                      try {
                        await ref.read(authProvider.notifier).updateEmail(
                              newEmail: newEmailController.text.trim(),
                              currentPassword: passwordController.text,
                            );
                        if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.emailChangeSent)),
                          );
                        }
                      } on AuthException catch (e) {
                        setDialogState(() => isSubmitting = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(mapAuthErrorCode(l10n, e.code)), backgroundColor: AppColors.error),
                          );
                        }
                      }
                    },
              child: Text(l10n.saveChanges, style: AppTextStyles.link),
            ),
          ],
        ),
      ),
    );
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
              AuthTopBar(title: l10n.editProfile),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spaceLg,
                    AppConstants.spaceMd,
                    AppConstants.spaceLg,
                    AppConstants.spaceXl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: AvatarPicker(
                          initialImage: _profileImage,
                          initialNetworkUrl: ref.watch(authProvider)?.photoUrl,
                          onChanged: (file) => setState(() => _profileImage = file),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceXl),
                      LuxuryTextField(
                        label: l10n.fullName,
                        controller: _fullNameController,
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: AppConstants.spaceMd),
                      LuxuryTextField(
                        label: l10n.username,
                        controller: _usernameController,
                        prefixIcon: Icons.alternate_email,
                      ),
                      const SizedBox(height: AppConstants.spaceMd),
                      LuxuryTextField(
                        label: l10n.phoneNumber,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: AppConstants.spaceMd),
                      LuxuryTextField(
                        label: l10n.email,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline,
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () => _showChangeEmailDialog(l10n),
                          child: Text(l10n.changeEmail, style: AppTextStyles.link),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceXl),
                      GoldGradientButton(
                        label: l10n.saveChanges,
                        isLoading: _isSaving,
                        onPressed: () => _save(l10n),
                      ),
                    ],
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
