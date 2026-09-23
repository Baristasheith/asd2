import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Square photo picker for the Admin dish form — shows the existing
/// photo (if editing), a newly-picked one, or an empty "tap to add a
/// photo" state. Uses the same Camera/Gallery bottom sheet pattern as
/// `AvatarPicker`, just in a 4:3-ish rectangle instead of a circle.
class DishImagePicker extends StatefulWidget {
  final String? initialNetworkUrl;
  final ValueChanged<File?> onChanged;

  const DishImagePicker({super.key, this.initialNetworkUrl, required this.onChanged});

  @override
  State<DishImagePicker> createState() => _DishImagePickerState();
}

class _DishImagePickerState extends State<DishImagePicker> {
  File? _image;

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 1600);
      if (picked == null) return;
      setState(() => _image = File(picked.path));
      widget.onChanged(_image);
    } catch (_) {
      // Camera/gallery unavailable or permission denied — keep current state.
    }
  }

  Future<void> _showPicker() async {
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
              label: 'Take Photo',
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(ImageSource.camera);
              },
            ),
            _SheetOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(ImageSource.gallery);
              },
            ),
            if (_image != null || widget.initialNetworkUrl != null)
              _SheetOption(
                icon: Icons.delete_outline,
                label: 'Remove Photo',
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
    final hasNetworkImage = _image == null && widget.initialNetworkUrl != null;

    return GestureDetector(
      onTap: _showPicker,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.surfaceCardElevated,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: AppColors.divider),
          image: _image != null
              ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
              : hasNetworkImage
                  ? DecorationImage(image: NetworkImage(widget.initialNetworkUrl!), fit: BoxFit.cover)
                  : null,
        ),
        child: (_image == null && !hasNetworkImage)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primarySage, size: 28),
                  const SizedBox(height: AppConstants.spaceSm),
                  Text('Add a photo', style: AppTextStyles.bodySmall),
                ],
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.all(AppConstants.spaceSm),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppColors.primarySage, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, size: 14, color: AppColors.textOnSage),
                ),
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
