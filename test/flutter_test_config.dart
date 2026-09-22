import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the app font for every test so text is measured like on a device
/// (the default test font renders each glyph as a wide square, which causes
/// false layout overflows with Cyrillic copy).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = FontLoader('Inter')
    ..addFont(rootBundle.load('assets/fonts/Inter-VariableFont_opsz,wght.ttf'));
  await loader.load();
  await testMain();
}
