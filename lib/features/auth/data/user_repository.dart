import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/auth_user.dart';

/// Thin wrapper around the `users/{uid}` Firestore collection. Kept
/// separate from `AuthNotifier` so the Firestore read/write logic is
/// independently testable and swappable (e.g. for a different backend)
/// without touching any auth flow code.
class UserRepository {
  final _users = FirebaseFirestore.instance.collection('users');

  Future<void> createOrUpdateProfile(AuthUser user) async {
    await _users.doc(user.uid).set(
          {
            ...user.toFirestore(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
  }

  Future<void> createProfileIfMissing(AuthUser user) async {
    final doc = await _users.doc(user.uid).get();
    if (!doc.exists) {
      await _users.doc(user.uid).set({
        ...user.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Merges any extra profile fields stored in Firestore (username,
  /// phone) onto the base identity Firebase Auth already gave us.
  Future<AuthUser> hydrate(AuthUser base) async {
    final doc = await _users.doc(base.uid).get();
    if (!doc.exists) return base;
    final data = doc.data()!;
    return base.copyWith(
      username: data['username'] as String?,
      phone: data['phone'] as String?,
      photoUrl: (data['photoUrl'] as String?) ?? base.photoUrl,
      fullName: (data['fullName'] as String?) ?? base.fullName,
      isAdmin: data['isAdmin'] as bool? ?? false,
    );
  }
}
