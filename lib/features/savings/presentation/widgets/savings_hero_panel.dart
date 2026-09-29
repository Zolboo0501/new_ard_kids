import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// A flat night hero panel with a faint [accent] wash from the top-left
/// corner, like the Home account panel.
class SavingsHeroPanel extends StatelessWidget {
  const SavingsHeroPanel({
    super.key,
    required this.child,
    this.accent,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
  });

  final Widget child;

  /// The wash colour; the theme accent when null.
  final Color? accent;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final wash = accent ?? AppColors.sky500;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: RadialGradient(
            center: const Alignment(-1, -1),
            radius: 1.2,
            colors: [wash.withValues(alpha: 0.16), wash.withValues(alpha: 0)],
          ),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
