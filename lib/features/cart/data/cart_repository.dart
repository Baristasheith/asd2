import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads/writes `users/{uid}/cart/{dishId}` — one document per dish in
/// the cart, with a `quantity` field. Using `FieldValue.increment` for
/// add/decrement means two rapid taps never race each other or
/// overwrite one another, which a plain read-then-write would risk.
class CartRepository {
  CollectionReference<Map<String, dynamic>> _cartRef(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('cart');

  Stream<Map<String, int>> streamCart(String uid) {
    return _cartRef(uid).snapshots().map(
          (snapshot) => {
            for (final doc in snapshot.docs) doc.id: ((doc.data()['quantity'] as num?) ?? 0).toInt(),
          },
        );
  }

  Future<void> add(String uid, String dishId) async {
    await _cartRef(uid).doc(dishId).set(
      {'quantity': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
  }

  Future<void> decrement(String uid, String dishId, int currentQuantity) async {
    if (currentQuantity <= 1) {
      await remove(uid, dishId);
      return;
    }
    await _cartRef(uid).doc(dishId).update({'quantity': FieldValue.increment(-1)});
  }

  Future<void> remove(String uid, String dishId) => _cartRef(uid).doc(dishId).delete();

  Future<void> clear(String uid) async {
    final snapshot = await _cartRef(uid).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
