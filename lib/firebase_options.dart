import 'package:firebase_core/firebase_core.dart';

/// Firebase Web configuration for project `la-finca-1394c`.
/// These values are intended for the browser and are not service-account
/// credentials. Realtime Database rules and Firebase Authentication protect
/// the editable content.
class DefaultFirebaseOptions {
  // This is a browser API key, not a password or service-account credential.
  // Keep the dart-define override so deployments can still use a restricted
  // GitHub Actions variable when one is available.
  static const apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
  );
  static bool get isConfigured => apiKey.isNotEmpty;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: apiKey,
    appId: '1:1089877198747:web:17fca0db100be1ab9f033e',
    messagingSenderId: '1089877198747',
    projectId: 'la-finca-1394c',
    authDomain: 'la-finca-1394c.firebaseapp.com',
    databaseURL: 'https://la-finca-1394c-default-rtdb.firebaseio.com',
  );

  static FirebaseOptions get currentPlatform => web;
}
