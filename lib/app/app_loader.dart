import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shows [AppLoadingScreen] while [load] runs, then reveals [builder].
///
/// The saved theme, avatar and biometric choice are read here instead of
/// before `runApp`, so the first Flutter frame is the loading screen rather
/// than a blank one. [builder] runs only after [load] finishes, so the app
/// never builds with the default blue theme and then flips to a saved pink.
///
/// The app is built as soon as [load] is done, underneath the opaque
/// loading screen, so its heavy first frame lands out of sight while the
/// logo still plays; its tickers stay paused until it is revealed, so the
/// first screen's entrance plays in view. When [minDuration] has passed too,
/// the loading screen simply fades away over the built app.
class AppLoader extends StatefulWidget {
  const AppLoader({
    super.key,
    required this.load,
    required this.builder,
    this.minDuration = Duration.zero,
  });

  final Future<void> Function() load;
  final WidgetBuilder builder;

  /// How long the loading screen stays at least, so its logo animation
  /// ([AppLoadingScreen.animation]) can play out on a fast start.
  final Duration minDuration;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  /// [AppLoader.load] has finished: the app is built underneath.
  bool _loaded = false;

  /// The loading screen has started to fade away: the app runs and takes
  /// the taps.
  bool _revealing = false;

  /// The loading screen has faded away and is gone from the tree.
  bool _revealed = false;

  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final shown = Future<void>.delayed(widget.minDuration);
    try {
      await widget.load();
    } catch (e) {
      // Each store already falls back to its default; this is a last guard so
      // the app never stays on the loading screen.
      debugPrint('AppLoader: load failed: $e');
    }
    if (!mounted) return;
    setState(() => _loaded = true);
    await shown;
    if (!mounted) return;
    setState(() => _revealing = true);
    await _reveal.forward();
    if (mounted) setState(() => _revealed = true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_loaded)
            // Paused while hidden; starts as the loading screen leaves.
            TickerMode(
              enabled: _revealing,
              child: KeyedSubtree(
                key: const ValueKey('app'),
                child: Builder(builder: widget.builder),
              ),
            ),
          if (!_revealed)
            FadeTransition(
              opacity: ReverseAnimation(
                CurvedAnimation(parent: _reveal, curve: Curves.easeOut),
              ),
              child: IgnorePointer(
                ignoring: _revealing,
                child: const AppLoadingScreen(key: ValueKey('loading')),
              ),
            ),
        ],
      ),
    );
  }
}

/// The first Flutter frame, on the native splash's white: a calm, cinematic
/// logo moment. The Ard Kids logo fades in while it grows gently into
/// place, a soft band of light glides across it as it keeps pushing in, and
/// it then zooms through towards the viewer and fades as the app comes in.
/// Smooth ease-in-out throughout, no overshoot. A spinner fades in only if
/// loading takes longer than all that. With reduced motion the logo is
/// simply there.
///
/// It is drawn before the saved theme is known, so it uses only fixed
/// colors, never the theme accent getters.
class AppLoadingScreen extends StatefulWidget {
  const AppLoadingScreen({super.key});

  /// How long the logo's moment takes.
  static const animation = Duration(milliseconds: 1800);

  @override
  State<AppLoadingScreen> createState() => _AppLoadingScreenState();
}

class _AppLoadingScreenState extends State<AppLoadingScreen>
    with SingleTickerProviderStateMixin {
  /// The spinner waits until the logo's moment has played, so a normal
  /// start never shows it.
  static const _spinnerDelay = Duration(milliseconds: 2000);

  late final AnimationController _logo = AnimationController(
    vsync: this,
    duration: AppLoadingScreen.animation,
  );

  /// In, then out as it zooms through.
  late final Animation<double> _opacity = TweenSequence([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 30,
    ),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 25,
    ),
  ]).animate(_logo);

  /// Grows gently into place, keeps pushing in slowly, then accelerates
  /// towards the viewer.
  late final Animation<double> _scale = TweenSequence([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.92,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.05,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 40,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.05,
        end: 1.7,
      ).chain(CurveTween(curve: Curves.easeInCubic)),
      weight: 25,
    ),
  ]).animate(_logo);

  /// Where the light band is across the logo, from off its left edge to
  /// off its right.
  late final Animation<double> _shine = Tween(begin: -0.6, end: 1.6).animate(
    CurvedAnimation(
      parent: _logo,
      curve: const Interval(0.3, 0.75, curve: Curves.easeInOut),
    ),
  );

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still) {
      // The logo, settled: past its fade-in, before the zoom.
      _logo.value = 0.5;
    } else if (!_logo.isAnimating && _logo.value == 0) {
      _logo.forward();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _logo.dispose();
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
            // Fade and scale run as transitions on their own layer, so the
            // zoom never rebuilds the tree or repaints the rest of the
            // screen; the light band is masked in only while it sweeps.
            RepaintBoundary(
              child: FadeTransition(
                opacity: _opacity,
                child: ScaleTransition(
                  scale: _scale,
                  child: AnimatedBuilder(
                    animation: _shine,
                    builder: (context, child) {
                      final x = _shine.value;
                      // Off the logo on either side: no mask at all.
                      if (x <= -0.2 || x >= 1.2) return child!;
                      return ShaderMask(
                        blendMode: BlendMode.srcATop,
                        shaderCallback: (rect) => LinearGradient(
                          begin: const Alignment(-1, -0.4),
                          end: const Alignment(1, 0.4),
                          colors: const [
                            Color(0x00FFFFFF),
                            Color(0x66FFFFFF),
                            Color(0x00FFFFFF),
                          ],
                          stops: [
                            (x - 0.18).clamp(0.0, 1.0),
                            x.clamp(0.0, 1.0),
                            (x + 0.18).clamp(0.0, 1.0),
                          ],
                        ).createShader(rect),
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/images/ard_kids_logo.webp',
                      width: 260,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      semanticLabel: 'Ard Kids',
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.55),
              child: AnimatedOpacity(
                opacity: _showSpinner ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: SizedBox.square(
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
