import 'package:firebase_core/firebase_core.dart';

/// Firebase Web configuration for project `la-finca-1394c`.
/// These values are intended for the browser and are not service-account
/// credentials. Firestore rules and Firebase Authentication protect data.
class DefaultFirebaseOptions {
  static const isConfigured = true;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REDACTED_FIREBASE_API_KEY',
    appId: '1:1089877198747:web:17fca0db100be1ab9f033e',
    messagingSenderId: '1089877198747',
    projectId: 'la-finca-1394c',
    authDomain: 'la-finca-1394c.firebaseapp.com',
    storageBucket: 'la-finca-1394c.firebasestorage.app',
  );

  static FirebaseOptions get currentPlatform => web;
}
