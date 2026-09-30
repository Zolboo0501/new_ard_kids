import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_theme.dart';

/// Keeps the "Харагдац" choices (accent and light/dark mode) in secure
/// storage so they survive an app restart.
///
/// Storage errors never reach the UI: a failed read keeps the defaults
/// (sky accent, following the phone) and a failed write keeps the choice
/// for this session only.
abstract final class ThemeStore {
  static const _key = 'app_theme';
  static const _brightnessKey = 'app_brightness';
  static const _storage = FlutterSecureStorage();

  /// Applies the saved choices to [appThemeChoice] and [appBrightness].
  /// Called before the app is built.
  static Future<void> load() async {
    try {
      final saved = await _storage.read(key: _key);
      final choice = AppThemeChoice.values.asNameMap()[saved];
      if (choice != null) appThemeChoice.value = choice;
      final mode = await _storage.read(key: _brightnessKey);
      final brightness = AppBrightness.values.asNameMap()[mode];
      if (brightness != null) appBrightness.value = brightness;
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

  static Future<void> saveBrightness(AppBrightness brightness) async {
    try {
      await _storage.write(key: _brightnessKey, value: brightness.name);
    } catch (e) {
      debugPrint('ThemeStore.saveBrightness failed: $e');
    }
  }
}
