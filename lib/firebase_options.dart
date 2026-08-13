import 'package:firebase_core/firebase_core.dart';

/// Firebase Web configuration for project `la-finca-1394c`.
/// These values are intended for the browser and are not service-account
/// credentials. Realtime Database rules and Firebase Authentication protect
/// the editable content.
class DefaultFirebaseOptions {
  // Injected only by GitHub Actions with --dart-define. It is intentionally
  // absent from the repository source and local builds without it use local
  // fallback content.
  static const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const isConfigured = apiKey.isNotEmpty;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: apiKey,
    appId: '1:1089877198747:web:17fca0db100be1ab9f033e',
    messagingSenderId: '1089877198747',
    projectId: 'la-finca-1394c',
    authDomain: 'la-finca-1394c.firebaseapp.com',
    storageBucket: 'la-finca-1394c.firebasestorage.app',
    databaseURL: 'https://la-finca-1394c-default-rtdb.firebaseio.com',
  );

  static FirebaseOptions get currentPlatform => web;
}
