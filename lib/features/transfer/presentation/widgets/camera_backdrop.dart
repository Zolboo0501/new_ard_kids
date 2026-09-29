import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// Dark fill shown until the camera's first frame (and behind errors).
class CameraBackdrop extends StatelessWidget {
  const CameraBackdrop({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Night.surface2, Night.surface, Night.bg],
        ),
      ),
      child: SizedBox.expand(child: child),
    );
  }
}
