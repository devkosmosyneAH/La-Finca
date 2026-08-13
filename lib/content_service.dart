import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'firebase_options.dart';
import 'site_content.dart';

class ContentService {
  static const documentPath = 'site/content';

  static bool get isConfigured => DefaultFirebaseOptions.isConfigured;

  static Future<SiteContent> load() async {
    if (!isConfigured) return SiteContent.defaults;
    final snapshot = await FirebaseDatabase.instance.ref(documentPath).get();
    final raw = snapshot.value;
    if (raw is Map) {
      final data = raw.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      return SiteContent.fromMap(Map<String, dynamic>.from(data));
    }
    return SiteContent.defaults;
  }

  static Future<UserCredential> signIn(String email, String password) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> signOut() => FirebaseAuth.instance.signOut();

  static Future<void> save(SiteContent content) {
    return FirebaseDatabase.instance.ref(documentPath).set(content.toMap());
  }
}
