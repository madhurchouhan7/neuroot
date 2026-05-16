import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:neuroot/firebase_options.dart';

/// Thin wrapper around Firebase.initializeApp().
/// Called once from main() before runApp.
class FirebaseService {
  FirebaseService._();

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      debugPrint('[FirebaseService] Firebase initialized ✅');
    }
  }
}
