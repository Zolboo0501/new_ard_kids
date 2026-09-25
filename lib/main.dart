import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'app/app_loader.dart';
import 'app/avatar.dart';
import 'app/biometrics.dart';
import 'app/routes.dart';
import 'theme/app_theme.dart';
import 'theme/theme_store.dart';
import 'widgets/adaptive.dart';

void main() {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Phones stay upright: the keypad screens need a portrait height. Tablets
  // rotate freely, and their layouts restructure for the width instead.
  final view = binding.platformDispatcher.implicitView;
  if (view != null &&
      (view.physicalSize / view.devicePixelRatio).shortestSide <
          AppLayout.tabletMin) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  // The loading screen shows while the saved choices are read; the app is
  // built only after, so a saved pink theme doesn't flash blue.
  runApp(
    AppLoader(
      load: () => Future.wait([
        ThemeStore.load(),
        AvatarStore.load(),
        BiometricStore.load(),
      ]),
      builder: (_) => const ArdKidsApp(),
    ),
  );
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
    appThemeChoice.addListener(_rebuildAll);
    appAvatar.addListener(_rebuildAll);
  }

  /// `AppColors` accent tokens and `Stickers` are read during build, so every
  /// element has to rebuild (const subtrees and routes under the stack
  /// included) to pick up a new palette or companion. Navigation and screen
  /// state are kept.
  void _rebuildAll() {
    setState(() {});
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  void dispose() {
    appThemeChoice.removeListener(_rebuildAll);
    appAvatar.removeListener(_rebuildAll);
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
      builder: AppScale.builder,
    );
  }
}
