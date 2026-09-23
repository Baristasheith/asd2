import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/localization/generated/app_localizations.dart';

/// Maps a `FirebaseAuthException.code` (a stable, English, machine
/// identifier) to a localized, user-facing message. Keeping this
/// mapping in one place means every screen shows a consistent message
/// for the same underlying error, in whichever of the 4 languages is
/// active.
String mapAuthErrorCode(AppLocalizations l10n, String code) {
  switch (code) {
    case 'email-already-in-use':
      return l10n.errorEmailInUse;
    case 'weak-password':
      return l10n.errorWeakPassword;
    case 'invalid-email':
      return l10n.errorInvalidEmail;
    case 'user-not-found':
      return l10n.errorUserNotFound;
    case 'wrong-password':
    case 'invalid-credential':
      return l10n.errorWrongPassword;
    case 'network-request-failed':
      return l10n.errorNetworkFailed;
    default:
      return l10n.errorGeneric;
  }
}
