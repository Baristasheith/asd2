import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/auth_user.dart';
import 'storage_repository.dart';
import 'user_repository.dart';

/// Thrown by every method below with a stable `code` — the same code
/// FirebaseAuthException uses (e.g. 'email-already-in-use',
/// 'wrong-password') or 'generic'/'network-request-failed' for
/// non-Firebase failures. Screens localize it via `mapAuthErrorCode`
/// rather than showing a raw SDK message.
class AuthException implements Exception {
  final String code;
  const AuthException(this.code);
  @override
  String toString() => code;
}

/// Single source of truth for "who is signed in", backed by real
/// Firebase Authentication — sessions persist automatically across app
/// restarts (that's Firebase's job, not ours). Extra profile fields
/// (username, phone, custom photo) live in Firestore and get merged
/// onto the Firebase Auth identity via [UserRepository.hydrate].
class AuthNotifier extends StateNotifier<AuthUser?> {
  AuthNotifier() : super(null) {
    _authSub = fb.FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  final _firebaseAuth = fb.FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final _userRepository = UserRepository();
  final _storageRepository = StorageRepository();

  late final _authSub;
  bool _isHydrating = false;

  Future<void> _onAuthChanged(fb.User? firebaseUser) async {
    if (firebaseUser == null) {
      state = null;
      return;
    }

    final base = AuthUser(
      uid: firebaseUser.uid,
      fullName: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      provider: _resolveProvider(firebaseUser),
    );

    // Show the base identity immediately (fast, no network round trip),
    // then enrich it with Firestore's username/phone once available.
    state = base;
    _isHydrating = true;
    try {
      state = await _userRepository.hydrate(base);
    } finally {
      _isHydrating = false;
    }
  }

  AuthProvider _resolveProvider(fb.User user) {
    final ids = user.providerData.map((p) => p.providerId);
    if (ids.contains('google.com')) return AuthProvider.google;
    if (ids.contains('facebook.com')) return AuthProvider.facebook;
    return AuthProvider.email;
  }

  Future<void> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return; // user cancelled the picker

      final googleAuth = await account.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        await _userRepository.createProfileIfMissing(
          AuthUser(
            uid: user.uid,
            fullName: user.displayName ?? account.displayName ?? '',
            email: user.email ?? account.email,
            photoUrl: user.photoURL ?? account.photoUrl,
            provider: AuthProvider.google,
          ),
        );
      }
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } catch (_) {
      throw const AuthException('generic');
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
      if (result.status == LoginStatus.cancelled) return;
      if (result.status != LoginStatus.success || result.accessToken == null) {
        throw const AuthException('generic');
      }

      final credential = fb.FacebookAuthProvider.credential(result.accessToken!.tokenString);
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final fbData = await FacebookAuth.instance.getUserData(fields: 'name,email,picture.width(200)');
        await _userRepository.createProfileIfMissing(
          AuthUser(
            uid: user.uid,
            fullName: user.displayName ?? (fbData['name'] as String?) ?? '',
            email: user.email ?? (fbData['email'] as String?) ?? '',
            photoUrl: user.photoURL ?? (fbData['picture']?['data']?['url'] as String?),
            provider: AuthProvider.facebook,
          ),
        );
      }
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('generic');
    }
  }

  Future<void> signUpWithEmail({
    required String fullName,
    required String username,
    required String phone,
    required String email,
    required String password,
    File? photoFile,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthException('generic');

      await user.updateDisplayName(fullName);

      String? photoUrl;
      if (photoFile != null) {
        photoUrl = await _storageRepository.uploadAvatar(uid: user.uid, file: photoFile);
        await user.updatePhotoURL(photoUrl);
      }

      final authUser = AuthUser(
        uid: user.uid,
        fullName: fullName,
        email: email,
        username: username,
        phone: phone,
        photoUrl: photoUrl,
        provider: AuthProvider.email,
      );
      await _userRepository.createOrUpdateProfile(authUser);
      state = authUser;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('generic');
    }
  }

  Future<void> signInWithEmail({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      // `_onAuthChanged` (triggered by the sign-in above) handles hydrating
      // and setting `state` — nothing else to do here.
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } catch (_) {
      throw const AuthException('generic');
    }
  }

  Future<void> updateProfile({
    required String fullName,
    String? username,
    String? phone,
    File? newPhotoFile,
  }) async {
    final current = state;
    final firebaseUser = _firebaseAuth.currentUser;
    if (current == null || firebaseUser == null) return;

    try {
      String? photoUrl = current.photoUrl;
      if (newPhotoFile != null) {
        photoUrl = await _storageRepository.uploadAvatar(uid: current.uid, file: newPhotoFile);
        await firebaseUser.updatePhotoURL(photoUrl);
      }
      await firebaseUser.updateDisplayName(fullName);

      final updated = current.copyWith(
        fullName: fullName,
        username: username,
        phone: phone,
        photoUrl: photoUrl,
      );
      await _userRepository.createOrUpdateProfile(updated);
      state = updated;
    } catch (_) {
      throw const AuthException('generic');
    }
  }

  Future<void> updateEmail({required String newEmail, required String currentPassword}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) throw const AuthException('generic');

    try {
      final credential = fb.EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(credential);
      // Sends a confirmation link to the NEW address; Firebase only
      // swaps the email over once the user taps that link — this is
      // the modern, recommended flow (plain `updateEmail` is deprecated
      // because it let attackers take over an account's inbox silently).
      await user.verifyBeforeUpdateEmail(newEmail);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } catch (_) {
      throw const AuthException('generic');
    }
  }

  Future<void> signOut() async {
    final provider = state?.provider;
    try {
      if (provider == AuthProvider.google) {
        await _googleSignIn.signOut();
      } else if (provider == AuthProvider.facebook) {
        await FacebookAuth.instance.logOut();
      }
      await _firebaseAuth.signOut();
    } catch (_) {
      // Already clearing local state below regardless — a provider-side
      // sign-out failure (e.g. no network) shouldn't trap the user.
    }
    state = null;
  }

  bool get isHydrating => _isHydrating;

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthUser?>(
  (ref) => AuthNotifier(),
);

/// True only when the signed-in user's Firestore `isAdmin` field is
/// `true`. Used purely for UI gating (showing/hiding the Admin Panel
/// entry point) — the real enforcement lives in Firestore security
/// rules, since a client-side check alone can always be bypassed.
final isAdminProvider = Provider<bool>((ref) => ref.watch(authProvider)?.isAdmin ?? false);
