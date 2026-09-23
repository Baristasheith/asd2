import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/dish.dart';
import 'seed_menu_data.dart';

/// Reads/writes the `dishes` collection. Every screen that shows the
/// menu (Home, Menu, Favorites, Dish Details) goes through
/// `streamAll()` so they all stay in sync the instant a dish changes —
/// no manual refresh anywhere.
class MenuRepository {
  final _dishes = FirebaseFirestore.instance.collection('dishes');

  Stream<List<Dish>> streamAll() {
    return _dishes.snapshots().map(
          (snapshot) => snapshot.docs.map(Dish.fromFirestore).toList(),
        );
  }

  /// Populates `dishes` from the bundled seed catalog the first time
  /// it's ever empty, so a freshly-created Firebase project has
  /// something to show immediately. Safe to call on every app start —
  /// it's a no-op once the collection has at least one document.
  Future<void> seedIfEmpty() async {
    final existing = await _dishes.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final dish in SeedMenuData.dishes) {
      batch.set(_dishes.doc(dish.id), dish.toFirestore());
    }
    await batch.commit();
  }

  Future<Dish?> getById(String id) async {
    final doc = await _dishes.doc(id).get();
    if (!doc.exists) return null;
    return Dish.fromFirestore(doc);
  }

  /// Creates a new dish with an auto-generated id, or overwrites an
  /// existing one if `id` is provided (used by the Admin Panel's edit
  /// flow). Firestore security rules restrict this to admins only —
  /// see README "Admin Panel" section.
  Future<void> upsertDish(Dish dish, {String? id}) async {
    if (id != null) {
      await _dishes.doc(id).set(dish.toFirestore());
    } else {
      await _dishes.add(dish.toFirestore());
    }
  }

  Future<void> deleteDish(String id) => _dishes.doc(id).delete();

  /// A fresh, unused document id — requested by the Admin form *before*
  /// saving, so a newly-picked photo can be uploaded to
  /// `dishes/{id}.jpg` using the SAME id the dish will be saved under.
  String newId() => _dishes.doc().id;

  Future<String> uploadDishImage({required String dishId, required File file}) async {
    final ref = FirebaseStorage.instance.ref().child('dishes').child('$dishId.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
