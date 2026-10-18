import 'package:flutter/material.dart';

import '../../../../widgets/ui.dart';

/// The welcome screen's one button: a round accent button with an arrow,
/// inside a thin ring that fills by [progress] (the share of slides seen),
/// so the kid can tell how far along they are.
///
/// It has no text of its own; [label] ("Дараах", or "Эхлэх" on the last
/// slide) is what screen readers announce.
class WelcomeNextButton extends StatelessWidget {
  const WelcomeNextButton({
    super.key,
    required this.label,
    required this.progress,
    required this.color,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final double progress;
  final Color color;
  final Color foreground;
  final VoidCallback onPressed;

  static const _size = 64.0;
  static const _ring = 80.0;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onPressed,
        scale: 0.94,
        child: SizedBox.square(
          dimension: _ring,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The ring eases to the new share on each step.
              TweenAnimationBuilder<double>(
                tween: Tween(end: progress),
                duration: Duration(milliseconds: still ? 0 : 400),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => SizedBox.square(
                  dimension: _ring,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 3,
                    strokeCap: StrokeCap.round,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.16),
                  ),
                ),
              ),
              Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 20,
                      spreadRadius: -4,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: LineIcon(
                  LineGlyph.arrowRight,
                  size: 26,
                  stroke: 2,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
