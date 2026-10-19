import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shows a card in 3D: it floats gently on its own, leans towards the finger
/// while pressed (and springs back on release), with an edge for thickness,
/// a sheen that slides with the tilt and a shadow that shifts under it.
///
/// The finger is read with a raw [Listener], so a drag on the card still
/// scrolls the page around it. Under reduced motion the card neither floats
/// nor springs, but still follows the finger.
class CardTilt extends StatefulWidget {
  const CardTilt({
    super.key,
    required this.child,
    required this.radiusFraction,
  });

  /// The flat card, filling the width it is given.
  final Widget child;

  /// The card's corner radius as a share of its width, so the edge, sheen
  /// and shadow round off like the card does.
  final double radiusFraction;

  @override
  State<CardTilt> createState() => _CardTiltState();
}

class _CardTiltState extends State<CardTilt> with TickerProviderStateMixin {
  /// The farthest the finger tilts the card, in radians.
  static const _maxTilt = 0.22;

  /// The slow idle float, one full sway per period.
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  /// Brings a let-go card back to the float.
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  /// Where the finger tilts the card to, -1 to 1 on each axis.
  Offset _press = Offset.zero;
  Offset _released = Offset.zero;
  bool _pressed = false;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduceMotion) {
      _float.stop();
    } else if (!_float.isAnimating) {
      _float.repeat();
    }
  }

  @override
  void dispose() {
    _float.dispose();
    _settle.dispose();
    super.dispose();
  }

  void _follow(Offset local, Size size) {
    final x = (local.dx / size.width * 2 - 1).clamp(-1.0, 1.0);
    final y = (local.dy / size.height * 2 - 1).clamp(-1.0, 1.0);
    _settle.stop();
    setState(() {
      _pressed = true;
      _press = Offset(x, y);
    });
  }

  void _letGo() {
    setState(() {
      _pressed = false;
      _released = _press;
      _press = Offset.zero;
    });
    if (_reduceMotion) return;
    _settle.forward(from: 0);
  }

  /// The finger's share of the tilt right now: all of it while pressed,
  /// easing out (with a little overshoot) after release.
  Offset get _fingerTilt {
    if (_pressed) return _press;
    if (_reduceMotion || !_settle.isAnimating) return Offset.zero;
    return _released * (1 - Curves.easeOutBack.transform(_settle.value));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final radius = BorderRadius.circular(width * widget.radiusFraction);
        return Listener(
          onPointerDown: (e) => _follow(e.localPosition, context.size!),
          onPointerMove: (e) => _follow(e.localPosition, context.size!),
          onPointerUp: (_) => _letGo(),
          onPointerCancel: (_) => _letGo(),
          child: AnimatedBuilder(
            animation: Listenable.merge([_float, _settle]),
            builder: (context, child) {
              final phase = _float.value * math.pi * 2;
              final idle = _reduceMotion
                  ? Offset.zero
                  : Offset(math.sin(phase) * 0.35, math.cos(phase) * 0.2);
              // The finger takes over from the float while pressed.
              final finger = _fingerTilt;
              final weight = _pressed ? 0.0 : 1.0;
              final tilt = finger + idle * weight;
              // The pressed point sinks away from the viewer, as if the
              // finger pushed the card there.
              final rotY = -tilt.dx * _maxTilt;
              final rotX = tilt.dy * _maxTilt;

              Matrix4 at(double depth) => Matrix4.identity()
                ..setEntry(3, 2, 0.0014)
                ..rotateX(rotX)
                ..rotateY(rotY)
                ..translateByDouble(0, 0, depth, 1);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // The shadow on the "ground", sliding away from the light
                  // as the card turns.
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(-rotY * 40, 16 - rotX * 30),
                      child: Transform.scale(
                        scale: 0.92,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF0B1220,
                                ).withValues(alpha: 0.22),
                                blurRadius: 28,
                                spreadRadius: -4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // The card's edge: a few layers behind the face, so it
                  // shows its thickness on the side it turns away from.
                  for (final depth in const [5.0, 3.5, 2.0])
                    Positioned.fill(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: at(depth),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                            color: const Color(0xFFC9CED6),
                          ),
                        ),
                      ),
                    ),
                  Transform(
                    alignment: Alignment.center,
                    transform: at(0),
                    child: Stack(
                      children: [
                        child!,
                        // The sheen: a soft band of light that slides
                        // across as the card turns.
                        Positioned.fill(
                          child: IgnorePointer(
                            child: ClipRRect(
                              borderRadius: radius,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(
                                      -1.6 + tilt.dx * 1.4,
                                      -1 + tilt.dy * 0.8,
                                    ),
                                    end: Alignment(
                                      1.6 + tilt.dx * 1.4,
                                      1 + tilt.dy * 0.8,
                                    ),
                                    colors: [
                                      const Color(0x00FFFFFF),
                                      const Color(
                                        0xFFFFFFFF,
                                      ).withValues(alpha: 0.38),
                                      const Color(0x00FFFFFF),
                                    ],
                                    stops: const [0.3, 0.5, 0.7],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            child: widget.child,
          ),
        );
      },
    );
  }
}
