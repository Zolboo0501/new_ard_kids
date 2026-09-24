import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shows [AppLoadingScreen] while [load] runs, then fades to [builder].
///
/// The saved theme, avatar and biometric choice are read here instead of
/// before `runApp`, so the first Flutter frame is the loading screen rather
/// than a blank one. [builder] runs only after [load] finishes, so the app
/// never builds with the default blue theme and then flips to a saved pink.
class AppLoader extends StatefulWidget {
  const AppLoader({super.key, required this.load, required this.builder});

  final Future<void> Function() load;
  final WidgetBuilder builder;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    try {
      await widget.load();
    } catch (e) {
      // Each store already falls back to its default; this is a last guard so
      // the app never stays on the loading screen.
      debugPrint('AppLoader: load failed: $e');
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        child: _ready
            ? KeyedSubtree(
                key: const ValueKey('app'),
                child: Builder(builder: widget.builder),
              )
            : const AppLoadingScreen(key: ValueKey('loading')),
      ),
    );
  }
}

/// The first Flutter frame. It continues the native splash
/// (`flutter_native_splash.yaml`: white background, centered logo) and adds
/// a spinner that only fades in if loading takes longer than a moment, so a
/// fast start doesn't flash it.
///
/// It is drawn before the saved theme is known, so it uses only fixed
/// colors, never the theme accent getters.
class AppLoadingScreen extends StatefulWidget {
  const AppLoadingScreen({super.key});

  @override
  State<AppLoadingScreen> createState() => _AppLoadingScreenState();
}

class _AppLoadingScreenState extends State<AppLoadingScreen> {
  static const _spinnerDelay = Duration(milliseconds: 400);

  bool _showSpinner = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_spinnerDelay, () {
      if (mounted) setState(() => _showSpinner = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ачаалж байна',
      child: ColoredBox(
        // Matches the native splash color, see flutter_native_splash.yaml.
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // flutter_native_splash treats the 447px logo as @4x, so it
            // shows at ~112 logical px; same size here for a seamless handoff.
            Image.asset('assets/images/logo.jpeg', width: 112, height: 112),
            Align(
              alignment: const Alignment(0, 0.45),
              child: AnimatedOpacity(
                opacity: _showSpinner ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: const SizedBox.square(
                  dimension: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    strokeCap: StrokeCap.round,
                    color: AppColors.slate300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
