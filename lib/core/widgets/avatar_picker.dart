import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_constants.dart';
import '../localization/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable circular avatar picker: shows the selected photo (or a
/// placeholder icon), a small gold camera badge, and — on tap — a
/// luxury bottom sheet with Camera / Gallery / Remove options.
///
/// Used by both Signup and Edit Profile so the picking UX is identical
/// everywhere in the app.
class AvatarPicker extends StatefulWidget {
  final File? initialImage;
  final String? initialNetworkUrl;
  final ValueChanged<File?> onChanged;
  final double size;

  const AvatarPicker({
    super.key,
    this.initialImage,
    this.initialNetworkUrl,
    required this.onChanged,
    this.size = 96,
  });

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  File? _image;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _image = widget.initialImage;
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 1024);
      if (picked == null) return;
      setState(() => _image = File(picked.path));
      widget.onChanged(_image);
    } catch (_) {
      // Camera/gallery permission denied or unavailable on this platform
      // (e.g. running on an emulator without a camera). Fail silently —
      // the user simply keeps the placeholder avatar.
    }
  }

  Future<void> _showPicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spaceLg,
          AppConstants.spaceMd,
          AppConstants.spaceLg,
          AppConstants.spaceXl,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppConstants.spaceLg),
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4)),
            ),
            _SheetOption(
              icon: Icons.camera_alt_outlined,
              label: l10n.takePhoto,
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(ImageSource.camera);
              },
            ),
            _SheetOption(
              icon: Icons.photo_library_outlined,
              label: l10n.chooseFromGallery,
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(ImageSource.gallery);
              },
            ),
            if (_image != null)
              _SheetOption(
                icon: Icons.delete_outline,
                label: l10n.removePhoto,
                color: AppColors.error,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  setState(() => _image = null);
                  widget.onChanged(null);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () => _showPicker(context),
      child: AnimatedScale(
        scale: _scale,
        duration: AppConstants.fastAnim,
        child: Stack(
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.sageGradient),
              child: CircleAvatar(
                backgroundColor: AppColors.surfaceCardElevated,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (widget.initialNetworkUrl != null ? NetworkImage(widget.initialNetworkUrl!) : null) as ImageProvider?,
                child: (_image == null && widget.initialNetworkUrl == null)
                    ? Icon(Icons.camera_alt_outlined, color: AppColors.primarySage, size: widget.size * 0.3)
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.primarySage, shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 14, color: AppColors.textOnSage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SheetOption({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primarySage, size: 22),
            const SizedBox(width: AppConstants.spaceMd),
            Text(label, style: AppTextStyles.bodyLarge.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
