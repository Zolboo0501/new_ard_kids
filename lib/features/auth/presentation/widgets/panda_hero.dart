import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/common.dart';

class PandaHero extends StatelessWidget {
  const PandaHero({super.key, this.size = 176});

  /// Side of the square the mascot is laid out in. The glow and the image
  /// keep the proportions of the original 176px hero.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          MascotImage(
            asset: 'assets/images/mascot_panda_key.png',
            size: size * 0.909,
            background: AppColors.dsSurface,
            semanticLabel: 'Алтан түлхүүр барьсан панда',
          ),
        ],
      ),
    );
  }
}
