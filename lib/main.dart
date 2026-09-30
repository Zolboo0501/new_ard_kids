import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'app/age_group.dart';
import 'app/app_loader.dart';
import 'app/avatar.dart';
import 'app/biometrics.dart';
import 'app/routes.dart';
import 'app/onboarding_store.dart';
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
        AvatarStore.load()
            .then((_) => AgeGroupStore.load())
            .then(
              // The saved avatar may be one the saved age range doesn't have.
              (_) => appAvatar.value = appAvatar.value.inAge(appAgeGroup.value),
            ),
        BiometricStore.load(),
        OnboardingStore.load(),
      ]),
      builder: (_) => ArdKidsApp(
        initialLocation: OnboardingStore.seen
            ? AppRoutes.auth
            : AppRoutes.welcome,
      ),
    ),
  );
}

class ArdKidsApp extends StatefulWidget {
  const ArdKidsApp({super.key, this.initialLocation = AppRoutes.auth});

  final String initialLocation;

  @override
  State<ArdKidsApp> createState() => _ArdKidsAppState();
}

class _ArdKidsAppState extends State<ArdKidsApp> with WidgetsBindingObserver {
  late final GoRouter _router = AppRoutes.createRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appThemeChoice.addListener(_rebuildAll);
    appBrightness.addListener(_rebuildAll);
    appAvatar.addListener(_rebuildAll);
    appAgeGroup.addListener(_rebuildAll);
  }

  /// With "Систем" picked, the canvas follows the phone's dark mode.
  @override
  void didChangePlatformBrightness() {
    if (appBrightness.value == AppBrightness.system) _rebuildAll();
  }

  /// `AppColors` tokens and `Stickers` are read during build, so every
  /// element has to rebuild (const subtrees and routes under the stack
  /// included) to pick up a new palette or companion. Navigation and screen
  /// state are kept.
  void _rebuildAll() {
    setState(() {});
    // Iterative, not recursive: the tree is thousands of elements deep on
    // Home (lists, card art, stickers), and a recursive visit overflowed
    // the Dart stack, taking the app down on a theme or age change.
    final pending = <Element>[];
    (context as Element).visitChildren(pending.add);
    while (pending.isNotEmpty) {
      final element = pending.removeLast();
      element.markNeedsBuild();
      element.visitChildren(pending.add);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appThemeChoice.removeListener(_rebuildAll);
    appBrightness.removeListener(_rebuildAll);
    appAvatar.removeListener(_rebuildAll);
    appAgeGroup.removeListener(_rebuildAll);
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ard',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
      // Status bar icons contrast with the canvas: light on dark, dark on
      // light.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppColors.isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: AppScale.builder(context, child),
      ),
    );
  }
}
