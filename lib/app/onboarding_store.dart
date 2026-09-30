import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// First-run introduction; failures keep navigation usable for this session.
abstract final class OnboardingStore {
  static const _storage = FlutterSecureStorage();
  static const key = 'onboarding_intro_seen';
  static bool seen = false;

  static Future<void> load() async {
    try {
      seen = await _storage.read(key: key) == 'true';
    } catch (e) {
      debugPrint('OnboardingStore.load failed: $e');
    }
  }

  static Future<void> complete() async {
    seen = true;
    try {
      await _storage.write(key: key, value: 'true');
    } catch (e) {
      debugPrint('OnboardingStore.complete failed: $e');
    }
  }
}
