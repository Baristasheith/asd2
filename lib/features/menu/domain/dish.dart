import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// A single menu item, backed by a `dishes/{id}` Firestore document.
///
/// `imageUrl` is optional — dishes added before a photo existed (or via
/// the seed catalog) fall back to a themed icon derived from the
/// category. `DishImagePlaceholder` handles both cases: it shows the
/// real photo when `imageUrl` is set, otherwise the icon-on-gradient
/// placeholder.
enum DishCategory { starters, mainCourse, desserts, beverages }

class Dish {
  final String id;
  final String name;
  final String description;
  final double price;
  final DishCategory category;
  final bool isFeatured;
  final String? imageUrl;

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.isFeatured = false,
    this.imageUrl,
  });

  IconData get icon {
    switch (category) {
      case DishCategory.starters:
        return Icons.set_meal_outlined;
      case DishCategory.mainCourse:
        return Icons.restaurant_menu;
      case DishCategory.desserts:
        return Icons.cake_outlined;
      case DishCategory.beverages:
        return Icons.coffee_outlined;
    }
  }

  factory Dish.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Dish(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      category: DishCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => DishCategory.mainCourse,
      ),
      isFeatured: data['isFeatured'] as bool? ?? false,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'description': description,
        'price': price,
        'category': category.name,
        'isFeatured': isFeatured,
        'imageUrl': imageUrl,
      };
}
