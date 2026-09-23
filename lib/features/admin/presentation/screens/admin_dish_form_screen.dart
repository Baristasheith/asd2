import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_top_bar.dart';
import '../../../../core/widgets/dish_image_picker.dart';
import '../../../../core/widgets/gold_gradient_button.dart';
import '../../../../core/widgets/luxury_text_field.dart';
import '../../../menu/data/menu_providers.dart';
import '../../../menu/domain/dish.dart';

class AdminDishFormScreen extends ConsumerStatefulWidget {
  final Dish? existing;
  const AdminDishFormScreen({super.key, this.existing});

  @override
  ConsumerState<AdminDishFormScreen> createState() => _AdminDishFormScreenState();
}

class _AdminDishFormScreenState extends ConsumerState<AdminDishFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late DishCategory _category;
  late bool _isFeatured;
  bool _isSaving = false;

  File? _newImage;
  bool _imageRemoved = false;

  @override
  void initState() {
    super.initState();
    final d = widget.existing;
    _nameController = TextEditingController(text: d?.name ?? '');
    _descriptionController = TextEditingController(text: d?.description ?? '');
    _priceController = TextEditingController(text: d != null ? d.price.toStringAsFixed(2) : '');
    _category = d?.category ?? DishCategory.mainCourse;
    _isFeatured = d?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final price = double.tryParse(_priceController.text.trim());
    if (_nameController.text.trim().isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid name and price.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);
    final repo = ref.read(menuRepositoryProvider);
    // A photo upload needs the dish's final id as its filename, so we
    // resolve the id up front — reusing the existing one when editing,
    // or minting a fresh one when creating — instead of letting
    // Firestore auto-generate it after the fact.
    final dishId = widget.existing?.id ?? repo.newId();

    try {
      String? imageUrl = _imageRemoved ? null : widget.existing?.imageUrl;
      if (_newImage != null) {
        imageUrl = await repo.uploadDishImage(dishId: dishId, file: _newImage!);
      }

      final dish = Dish(
        id: dishId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        category: _category,
        isFeatured: _isFeatured,
        imageUrl: imageUrl,
      );

      await repo.upsertDish(dish, id: dishId);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Check your connection.'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              AuthTopBar(title: widget.existing == null ? 'Add Dish' : 'Edit Dish'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spaceLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DishImagePicker(
                        initialNetworkUrl: _imageRemoved ? null : widget.existing?.imageUrl,
                        onChanged: (file) => setState(() {
                          _newImage = file;
                          _imageRemoved = file == null;
                        }),
                      ),
                      const SizedBox(height: AppConstants.spaceLg),
                      LuxuryTextField(label: 'Name', controller: _nameController),
                      const SizedBox(height: AppConstants.spaceMd),
                      LuxuryTextField(label: 'Description', controller: _descriptionController),
                      const SizedBox(height: AppConstants.spaceMd),
                      LuxuryTextField(
                        label: 'Price',
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: AppConstants.spaceMd),
                      Text('Category', style: AppTextStyles.inputLabel),
                      const SizedBox(height: AppConstants.spaceSm),
                      Wrap(
                        spacing: AppConstants.spaceSm,
                        children: DishCategory.values.map((c) {
                          final selected = c == _category;
                          return ChoiceChip(
                            label: Text(c.name),
                            selected: selected,
                            onSelected: (_) => setState(() => _category = c),
                            selectedColor: AppColors.primarySage,
                            backgroundColor: AppColors.surfaceCard,
                            labelStyle: AppTextStyles.bodySmall.copyWith(
                              color: selected ? AppColors.textOnSage : AppColors.textPrimary,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppConstants.spaceMd),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Featured on Home', style: AppTextStyles.bodyMedium),
                        value: _isFeatured,
                        activeColor: AppColors.primarySage,
                        onChanged: (v) => setState(() => _isFeatured = v),
                      ),
                      const SizedBox(height: AppConstants.spaceXl),
                      GoldGradientButton(label: 'Save', isLoading: _isSaving, onPressed: _save),
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
