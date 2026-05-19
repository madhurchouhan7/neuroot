import 'package:hive_flutter/hive_flutter.dart';

/// Tracks whether the user has seen the pre-auth intro onboarding.
/// Persisted locally via Hive — survives app restarts but is cleared
/// on app uninstall (exactly what we want).
class IntroService {
  static const _boxName = 'app_meta';
  static const _introKey = 'has_seen_intro';

  static Future<bool> hasSeenIntro() async {
    final box = await Hive.openBox<bool>(_boxName);
    return box.get(_introKey, defaultValue: false)!;
  }

  static Future<void> markIntroSeen() async {
    final box = await Hive.openBox<bool>(_boxName);
    await box.put(_introKey, true);
  }
}
