import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_theme.dart';

/// Keeps the "Өнгөний тохиргоо" choice in secure storage so it survives an
/// app restart.
///
/// Storage errors never reach the UI: a failed read falls back to the blue
/// theme and a failed write keeps the theme for this session only.
abstract final class ThemeStore {
  static const _key = 'app_theme';
  static const _storage = FlutterSecureStorage();

  /// Applies the saved theme to [appThemeChoice]. Called before `runApp`.
  static Future<void> load() async {
    try {
      final saved = await _storage.read(key: _key);
      final choice = AppThemeChoice.values.asNameMap()[saved];
      if (choice != null) appThemeChoice.value = choice;
    } catch (e) {
      debugPrint('ThemeStore.load failed: $e');
    }
  }

  static Future<void> save(AppThemeChoice choice) async {
    try {
      await _storage.write(key: _key, value: choice.name);
    } catch (e) {
      debugPrint('ThemeStore.save failed: $e');
    }
  }
}
