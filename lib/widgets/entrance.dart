import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Builds and owns the curved slices of a staggered entrance.
///
/// A screen keeps one of these beside its [AnimationController], asks for a
/// slice per element, and calls [dispose] from its own `dispose`. Building the
/// slices once matters: a screen that calls `setState` on every keystroke
/// would otherwise allocate a fresh [CurvedAnimation] per element per frame.
///
/// ```dart
/// late final _stagger = EntranceStagger(_entrance);
/// late final _title = _stagger.slice(0.1);
/// ```
class EntranceStagger {
  EntranceStagger(this.controller);

  final AnimationController controller;
  final _slices = <CurvedAnimation>[];

  /// A slice beginning at [start] (a fraction of the whole entrance) and
  /// running for [span]. Slices are meant to overlap, so the elements flow
  /// into one another instead of arriving one at a time.
  Animation<double> slice(double start, {double span = 0.62}) {
    final curved = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start,
        (start + span).clamp(0.0, 1.0),
        curve: appEmphasizedDecelerate,
      ),
    );
    _slices.add(curved);
    return curved;
  }

  void dispose() {
    for (final s in _slices) {
      s.dispose();
    }
    _slices.clear();
  }
}

/// One element of a staggered entrance: fades in while rising by [offsetY]
/// pixels over its slice [t] (see [EntranceStagger]).
///
/// The rise is a paint-time transform rather than a layout change, so a
/// running entrance can never shift a scroll extent or cause an overflow.
class Entrance extends StatelessWidget {
  const Entrance({
    super.key,
    required this.t,
    required this.child,
    this.offsetY = 16,
    this.scaleFrom,
  });

  /// This element's already-curved slice of the entrance.
  final Animation<double> t;

  /// How far the element rises into place.
  final double offsetY;

  /// When set, the element also scales up from this factor.
  final double? scaleFrom;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: t,
      // `child` is built by the caller and handed to the builder, so a running
      // entrance repaints without rebuilding the subtree underneath it.
      child: child,
      builder: (context, child) {
        final v = t.value;
        Widget result = Transform.translate(
          offset: Offset(0, offsetY * (1 - v)),
          child: child,
        );
        if (scaleFrom != null) {
          result = Transform.scale(
            scale: scaleFrom! + (1 - scaleFrom!) * v,
            child: result,
          );
        }
        // RenderOpacity paints straight through at 1.0, so leaving this in
        // costs nothing once the entrance has settled.
        return Opacity(opacity: v, child: result);
      },
    );
  }
}
