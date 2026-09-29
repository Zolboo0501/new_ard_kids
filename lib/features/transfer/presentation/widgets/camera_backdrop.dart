import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// Dark fill shown until the camera's first frame (and behind errors).
class CameraBackdrop extends StatelessWidget {
  const CameraBackdrop({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.slate50, AppColors.card, AppColors.surface],
        ),
      ),
      child: SizedBox.expand(child: child),
    );
  }
}
