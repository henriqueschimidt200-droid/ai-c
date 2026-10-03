// Configure this file with FlutterFire before building a real release.
// Run: dart pub global activate flutterfire_cli
// Then: flutterfire configure
//
// This placeholder lets the project source be distributed without exposing
// any Firebase project credentials.

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase is not configured yet. Run "flutterfire configure" '
      'to generate lib/firebase_options.dart for your Firebase project.',
    );
  }
}
