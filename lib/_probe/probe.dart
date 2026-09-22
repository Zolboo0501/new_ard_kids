import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const s = FlutterSecureStorage();
  try {
    final before = await s.read(key: 'app_theme');
    debugPrint('PROBE before=$before');
    await s.write(key: 'app_theme', value: 'pink');
    debugPrint('PROBE after=${await s.read(key: 'app_theme')}');
  } catch (e) {
    debugPrint('PROBE error=$e');
  }
  runApp(const SizedBox());
}
