// File generated normally by the `flutterfire configure` CLI command.
//
// ⚠️ THIS IS A PLACEHOLDER. The values below are NOT real and Firebase
// will fail to initialize until you replace this entire file with the
// one generated for YOUR Firebase project. Steps:
//
//   1) Create a project at https://console.firebase.google.com
//   2) Install the CLI tools (one-time):
//        dart pub global activate flutterfire_cli
//   3) From the root of this Flutter project, run:
//        flutterfire configure
//      Follow the prompts, select your Firebase project, and pick the
//      platforms you're targeting (Android / iOS). This OVERWRITES this
//      file automatically with your real project's keys and also drops
//      `google-services.json` (Android) / `GoogleService-Info.plist`
//      (iOS) into the right native folders for you.
//
// See the "Firebase Setup" section in README.md for the full checklist
// (enabling Auth providers, creating Firestore, Storage rules, etc).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web — '
        'run `flutterfire configure` to add web support if needed.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ---- REPLACE EVERYTHING BELOW with the output of `flutterfire configure` ----

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME.appspot.com',
    iosBundleId: 'com.ahmadrestcafe.app',
  );
}
