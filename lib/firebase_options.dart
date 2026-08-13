import 'package:firebase_core/firebase_core.dart';

/// Firebase Web configuration for project `lafinca-7dc2c`.
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
    appId: '1:281822232208:web:838676afac4bbd79a12215',
    messagingSenderId: '281822232208',
    projectId: 'lafinca-7dc2c',
    authDomain: 'lafinca-7dc2c.firebaseapp.com',
    databaseURL: 'https://lafinca-7dc2c-default-rtdb.firebaseio.com',
  );

  static FirebaseOptions get currentPlatform => web;
}
