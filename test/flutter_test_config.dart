import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the app fonts for every test so text is measured like on a device
/// (the default test font renders each glyph as a wide square, which causes
/// false layout overflows with Cyrillic copy).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await (FontLoader('Inter')..addFont(
        rootBundle.load('assets/fonts/Inter-VariableFont_opsz,wght.ttf'),
      ))
      .load();
  // The display face on the character card art.
  await (FontLoader(
    'Nunito',
  )..addFont(rootBundle.load('assets/fonts/Nunito-Variable.ttf'))).load();
  // The icon font (Iconsax Outline), so icons render as on a device.
  await (FontLoader('packages/iconsax_flutter/FlutterIconsax')..addFont(
        rootBundle.load('packages/iconsax_flutter/fonts/FlutterIconsax.ttf'),
      ))
      .load();
  await testMain();
}
