/// Which flow authenticated the current user. Firebase Auth tracks its
/// own provider IDs internally; this is a simplified view just for UI
/// decisions (e.g. which sign-out call to make).
enum AuthProvider { google, facebook, email }

/// Merges Firebase Auth's core identity (uid, email, displayName,
/// photoURL) with the extra profile fields (username, phone) that only
/// live in the Firestore `users/{uid}` document — Firebase Auth itself
/// has no concept of "username" or "phone" beyond phone-auth sign-in.
class AuthUser {
  final String uid;
  final String fullName;
  final String email;
  final String? username;
  final String? phone;
  final String? photoUrl;
  final AuthProvider provider;
  final bool isAdmin;

  const AuthUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.provider,
    this.username,
    this.phone,
    this.photoUrl,
    this.isAdmin = false,
  });

  AuthUser copyWith({
    String? fullName,
    String? username,
    String? phone,
    String? photoUrl,
    bool? isAdmin,
  }) {
    return AuthUser(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      provider: provider,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'fullName': fullName,
        'email': email,
        'username': username,
        'phone': phone,
        'photoUrl': photoUrl,
        'provider': provider.name,
        // Note: `isAdmin` is intentionally NOT written back here — it
        // should only ever be set directly in the Firestore console (or
        // by a trusted Cloud Function), never by the client that reads
        // it. Writing it via toFirestore() would let a user grant
        // themselves admin. See README "Admin Panel" section.
      };
}
