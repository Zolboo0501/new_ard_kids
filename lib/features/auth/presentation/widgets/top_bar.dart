import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerRight,
      child: Image.asset(
        'assets/images/ard_logo.png',
        width: 36,
        height: 36,
        fit: BoxFit.contain,
        semanticLabel: 'Ard',
      ),
    );
  }
}
