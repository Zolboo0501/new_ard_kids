import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// The balance card at the top of the rewards and coin tabs: a flat night
/// panel with a faint wash of the account's [accent] from the top-left
/// corner, like Home's account panels.
class AccountHeroPanel extends StatelessWidget {
  const AccountHeroPanel({
    super.key,
    required this.accent,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Color accent;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        gradient: RadialGradient(
          center: const Alignment(-1, -1),
          radius: 1.2,
          colors: [
            Color.alphaBlend(accent.withValues(alpha: 0.16), AppColors.card),
            AppColors.card,
          ],
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
