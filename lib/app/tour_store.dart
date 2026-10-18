import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Which screens' avatar tours the teen has had: each screen's tour plays
/// once, on its first visit, and is then remembered here.
///
/// Off until [load] runs at start-up, so screens built without the loader
/// (tests) never show tours; a storage failure skips them for the session.
abstract final class TourStore {
  static const _storage = FlutterSecureStorage();
  static const _prefix = 'tour_done_';

  /// Whether tours can show at all this session.
  static bool enabled = false;
  static final _done = <String>{};

  /// The storage key for the tour of screen [id].
  static String keyFor(String id) => '$_prefix$id';

  static Future<void> load() async {
    try {
      final all = await _storage.readAll();
      _done
        ..clear()
        ..addAll(
          all.keys
              .where((k) => k.startsWith(_prefix) && all[k] == 'true')
              .map((k) => k.substring(_prefix.length)),
        );
      enabled = true;
    } catch (e) {
      debugPrint('TourStore.load failed: $e');
    }
  }

  /// Whether screen [id] still owes the teen its tour.
  static bool pending(String id) => enabled && !_done.contains(id);

  /// Screen [id]'s tour has been shown: never again.
  static Future<void> complete(String id) async {
    _done.add(id);
    try {
      await _storage.write(key: keyFor(id), value: 'true');
    } catch (e) {
      debugPrint('TourStore.complete failed: $e');
    }
  }

  /// Forgets what was shown and turns tours on; for tests.
  @visibleForTesting
  static void reset({bool enabled = false}) {
    _done.clear();
    TourStore.enabled = enabled;
  }
}
