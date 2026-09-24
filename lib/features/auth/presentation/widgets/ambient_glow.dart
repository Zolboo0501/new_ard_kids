import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class AmbientGlow extends StatelessWidget {
  const AmbientGlow({super.key});

  @override
  Widget build(BuildContext context) {
    Widget blob(double size, Color color) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -96,
            left: -80,
            child: blob(360, AppColors.sky200.withValues(alpha: 0.45)),
          ),
          Positioned(
            top: 40,
            right: -80,
            child: blob(320, AppColors.indigo100.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}
