import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads/writes `users/{uid}/favorites/{dishId}` — the document's
/// existence IS the favorite state, so toggling is just add-or-delete.
class FavoritesRepository {
  CollectionReference<Map<String, dynamic>> _favoritesRef(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('favorites');

  Stream<Set<String>> streamIds(String uid) {
    return _favoritesRef(uid).snapshots().map(
          (snapshot) => snapshot.docs.map((d) => d.id).toSet(),
        );
  }

  Future<void> add(String uid, String dishId) {
    return _favoritesRef(uid).doc(dishId).set({'addedAt': FieldValue.serverTimestamp()});
  }

  Future<void> remove(String uid, String dishId) {
    return _favoritesRef(uid).doc(dishId).delete();
  }
}
