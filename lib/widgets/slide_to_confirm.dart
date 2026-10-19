import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'ui.dart';

/// A pill the kid confirms by sliding its round thumb from the left edge to
/// the right one. Let go short of the end and the thumb springs back; a tap
/// nudges it to show which way it goes. Screen readers get a plain button
/// that confirms on activation, since they can't drag.
///
/// Looks like `SubmitButton` (58pt accent pill with the accent glow), so it
/// can stand in for one at the bottom of a step.
class SlideToConfirm extends StatefulWidget {
  const SlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
  });

  final String label;
  final VoidCallback onConfirmed;

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm>
    with SingleTickerProviderStateMixin {
  static const _height = 58.0;
  static const _thumb = 46.0;
  static const _inset = 6.0;

  /// Past this share of the track, letting go completes the slide.
  static const _threshold = 0.85;

  /// The thumb's position along the track, 0 (left) to 1 (right).
  late final AnimationController _position = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );

  bool _done = false;
  double _travel = 1;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    _position.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  void _onDragUpdate(DragUpdateDetails d) {
    if (_done) return;
    _position.value += d.primaryDelta! / _travel;
  }

  void _onDragEnd(DragEndDetails d) {
    if (_done) return;
    final flung = (d.primaryVelocity ?? 0) > 900 && _position.value > 0.4;
    if (_position.value >= _threshold || flung) {
      _complete();
    } else {
      _springBack();
    }
  }

  void _springBack() {
    if (_reduceMotion) {
      _position.value = 0;
    } else {
      _position.animateTo(0, curve: Curves.easeOutBack);
    }
  }

  Future<void> _complete() async {
    if (_done) return;
    setState(() => _done = true);
    if (_reduceMotion) {
      _position.value = 1;
    } else {
      await _position.animateTo(
        1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
      );
    }
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    widget.onConfirmed();
    // Back to the start once the next screen covers this one, so returning
    // to it shows a fresh slider.
    _reset = Timer(const Duration(milliseconds: 600), () {
      setState(() => _done = false);
      _position.value = 0;
    });
  }

  Future<void> _nudge() async {
    if (_done || _position.isAnimating || _reduceMotion) return;
    HapticFeedback.selectionClick();
    await _position.animateTo(
      0.18,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
    if (!mounted || _done) return;
    await _position.animateTo(
      0,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutBack,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      onTap: _complete,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            _travel = (constraints.maxWidth - _thumb - _inset * 2).clamp(
              1.0,
              double.infinity,
            );
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _nudge,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: Container(
                width: double.infinity,
                height: _height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: AppColors.sky500,
                  boxShadow: AppColors.isDark
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.sky500.withValues(alpha: 0.32),
                            blurRadius: 22,
                            spreadRadius: -6,
                            offset: const Offset(0, 10),
                          ),
                        ],
                ),
                child: AnimatedBuilder(
                  animation: _position,
                  builder: (context, _) {
                    final t = _position.value;
                    final left = _inset + t * _travel;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // The caption fades as the thumb slides over it.
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _thumb + _inset * 2,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.label,
                              maxLines: 1,
                              style: inter(
                                size: 16,
                                weight: FontWeight.w700,
                                color: AppColors.onAccent.withValues(
                                  alpha: (1 - t * 1.6).clamp(0.0, 1.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: left,
                          child: Container(
                            width: _thumb,
                            height: _thumb,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.onAccent,
                            ),
                            alignment: Alignment.center,
                            child: LineIcon(
                              _done ? LineGlyph.check : LineGlyph.arrowRight,
                              size: 20,
                              color: AppColors.sky600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
