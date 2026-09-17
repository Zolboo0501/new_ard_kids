import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// How a route animates in (and back out when popped).
enum AppTransition {
  /// Slides in from the right while the page below drifts left and dims.
  /// Default for drilling into a screen with `context.push`.
  slide,

  /// Rises from the bottom with a fade, like a sheet. For task-style screens
  /// that are opened, finished and dismissed (QR scanner, receipt).
  rise,

  /// Cross-fades with a slight zoom. For `context.go` stack resets where
  /// there is no "previous" page to slide from (sign-in, home).
  fade,
}

/// Wraps [child] in a [CustomTransitionPage] using [transition].
///
/// Animations are skipped when the platform asks for reduced motion.
Page<void> buildTransitionPage({
  required GoRouterState state,
  required Widget child,
  AppTransition transition = AppTransition.slide,
}) {
  final (inDuration, outDuration) = switch (transition) {
    AppTransition.slide => (320, 260),
    AppTransition.rise => (380, 280),
    AppTransition.fade => (280, 220),
  };

  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.path,
    child: child,
    transitionDuration: Duration(milliseconds: inDuration),
    reverseTransitionDuration: Duration(milliseconds: outDuration),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      return switch (transition) {
        AppTransition.slide => _slide(animation, secondaryAnimation, child),
        AppTransition.rise => _rise(animation, child),
        AppTransition.fade => _fade(animation, child),
      };
    },
  );
}

Widget _slide(
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final incoming = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  final outgoing = CurvedAnimation(
    parent: secondaryAnimation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  // Page underneath: small parallax shift left and a light dim.
  final covered = SlideTransition(
    position: Tween(
      begin: Offset.zero,
      end: const Offset(-0.25, 0),
    ).animate(outgoing),
    child: child,
  );

  return SlideTransition(
    position: Tween(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(incoming),
    child: DecoratedBox(
      // Soft edge shadow so the incoming page reads as a layer on top.
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 24,
            offset: Offset(-4, 0),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          covered,
          // A translucent overlay is cheaper than a color filter layer.
          Positioned.fill(
            child: IgnorePointer(
              child: FadeTransition(
                opacity: outgoing,
                child: const ColoredBox(color: Color(0x140F172A)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _rise(Animation<double> animation, Widget child) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutQuart,
    reverseCurve: Curves.easeInCubic,
  );
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    ),
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    ),
  );
}

Widget _fade(Animation<double> animation, Widget child) {
  final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
  return FadeTransition(
    opacity: curved,
    child: ScaleTransition(
      scale: Tween(begin: 0.98, end: 1.0).animate(curved),
      child: child,
    ),
  );
}
