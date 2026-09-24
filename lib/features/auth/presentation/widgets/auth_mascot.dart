import 'package:flutter/material.dart';

import '../../../../widgets/ui.dart';

/// The red panda sticker, cut out onto a transparent background so it sits
/// straight on the page.
class AuthMascot extends StatelessWidget {
  const AuthMascot({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Mascots.redPandaCutout,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'Ard KIDS улаан панда',
    );
  }
}
