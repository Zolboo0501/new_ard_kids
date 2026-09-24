import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_tabs.dart';

/// Shared-axis switch for the form under the tabs. [AppTabView] can't be
/// used here: it holds the outgoing and incoming panes at once, and the text
/// fields' focus nodes can only be attached to one of them. Instead the one
/// form slides and fades out, swaps to the new [index] at the midpoint (so
/// the fields keep their text and focus), then slides and fades back in.
class ModeSwitch extends StatefulWidget {
  const ModeSwitch({super.key, required this.index, required this.builder});

  final int index;

  /// Builds the form for the index currently shown.
  final Widget Function(int shown) builder;

  @override
  State<ModeSwitch> createState() => _ModeSwitchState();
}

class _ModeSwitchState extends State<ModeSwitch>
    with SingleTickerProviderStateMixin {
  /// Fraction of the switch spent leaving; the rest is arriving.
  static const _outEnd = 0.35;
  static const _travel = 24.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    value: 1,
  )..addListener(_swapAtMidpoint);

  late int _shown = widget.index;

  /// 1 when moving to a later tab (content travels left), -1 for earlier.
  double _sign = 1;

  void _swapAtMidpoint() {
    if (_controller.value >= _outEnd && _shown != widget.index) {
      setState(() => _shown = widget.index);
    }
  }

  @override
  void didUpdateWidget(ModeSwitch old) {
    super.didUpdateWidget(old);
    if (old.index == widget.index) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _shown = widget.index;
      _controller.value = 1;
      return;
    }
    _sign = widget.index > old.index ? 1 : -1;
    // Tapped again while arriving: leave from the current opacity instead of
    // snapping back to fully visible.
    final v = _controller.value;
    final start = v <= _outEnd
        ? v
        : _outEnd * (1 - (v - _outEnd) / (1 - _outEnd));
    _controller.forward(from: start);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.builder(_shown),
      builder: (context, child) {
        final v = _controller.value;
        final double opacity;
        final double dx;
        if (v < _outEnd) {
          final t = appEmphasizedAccelerate.transform(v / _outEnd);
          opacity = 1 - t;
          dx = -_sign * _travel * t;
        } else {
          final t = appEmphasizedDecelerate.transform(
            (v - _outEnd) / (1 - _outEnd),
          );
          opacity = t;
          dx = _sign * _travel * (1 - t);
        }
        return Opacity(
          opacity: opacity,
          child: Transform.translate(offset: Offset(dx, 0), child: child),
        );
      },
    );
  }
}
