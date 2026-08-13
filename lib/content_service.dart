import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'site_content.dart';

class ContentService {
  static const documentPath = 'site/content';

  static bool get isConfigured => DefaultFirebaseOptions.isConfigured;

  static Future<SiteContent> load() async {
    if (!isConfigured) return SiteContent.defaults;
    final snapshot = await FirebaseFirestore.instance.doc(documentPath).get();
    return SiteContent.fromMap(snapshot.data() ?? const {});
  }

  static Future<UserCredential> signIn(String email, String password) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> signOut() => FirebaseAuth.instance.signOut();

  static Future<void> save(SiteContent content) {
    return FirebaseFirestore.instance.doc(documentPath).set(
          content.toMap(),
          SetOptions(merge: true),
        );
  }
}
