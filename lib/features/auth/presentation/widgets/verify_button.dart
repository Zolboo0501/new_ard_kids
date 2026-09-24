import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class VerifyButton extends StatelessWidget {
  const VerifyButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: withHaptic(enabled ? onPressed : null),
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.6,
          duration: const Duration(milliseconds: 200),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.dsPrimaryContainer,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  'Баталгаажуулах',
                  size: 14,
                  weight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.14,
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
