import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Whether Home still owes the teen its first-visit tour, led by their
/// avatar. Off until [load] finds it was never finished, so screens built
/// without the loader (tests) never see it; a storage failure skips it.
abstract final class HomeTourStore {
  static const _storage = FlutterSecureStorage();
  static const key = 'home_tour_done';

  /// True while the tour is still to be shown.
  static bool pending = false;

  static Future<void> load() async {
    try {
      pending = await _storage.read(key: key) != 'true';
    } catch (e) {
      debugPrint('HomeTourStore.load failed: $e');
    }
  }

  /// Finished or skipped: never show it again.
  static Future<void> complete() async {
    pending = false;
    try {
      await _storage.write(key: key, value: 'true');
    } catch (e) {
      debugPrint('HomeTourStore.complete failed: $e');
    }
  }
}
