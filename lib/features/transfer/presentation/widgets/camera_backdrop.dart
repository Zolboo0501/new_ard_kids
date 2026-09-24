import 'package:flutter/material.dart';

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
          colors: [Color(0xFF101B2B), Color(0xFF1A2838), Color(0xFF0F1A28)],
        ),
      ),
      child: SizedBox.expand(child: child),
    );
  }
}
