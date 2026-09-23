import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Uploads a profile picture to `avatars/{uid}.jpg` in Firebase Storage
/// and returns its public download URL. Kept as a single-purpose class
/// so Signup and Edit Profile both go through identical upload logic.
class StorageRepository {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadAvatar({required String uid, required File file}) async {
    final ref = _storage.ref().child('avatars').child('$uid.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
