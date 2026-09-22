import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app/routes.dart';
import 'theme/app_theme.dart';
import 'theme/theme_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Before the first frame, so a saved pink theme doesn't flash blue.
  await ThemeStore.load();
  runApp(const ArdKidsApp());
}

class ArdKidsApp extends StatefulWidget {
  const ArdKidsApp({super.key});

  @override
  State<ArdKidsApp> createState() => _ArdKidsAppState();
}

class _ArdKidsAppState extends State<ArdKidsApp> {
  late final GoRouter _router = AppRoutes.createRouter();

  @override
  void initState() {
    super.initState();
    appThemeChoice.addListener(_onThemeChanged);
  }

  /// `AppColors` accent tokens are read during build, so every element has
  /// to rebuild (const subtrees and routes under the stack included) to pick
  /// up the new palette. Navigation and screen state are kept.
  void _onThemeChanged() {
    setState(() {});
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  void dispose() {
    appThemeChoice.removeListener(_onThemeChanged);
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ard Kidsv2',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}
