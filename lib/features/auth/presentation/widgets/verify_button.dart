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
    final ink = enabled ? AppColors.onAccent : AppColors.slate500;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: withHaptic(enabled ? onPressed : null),
        // Until the code is complete it sits on a raised surface with muted
        // ink; a faded accent fill reads as a muddy teal on the dark canvas.
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: appEmphasizedDecelerate,
          height: 52,
          decoration: BoxDecoration(
            color: enabled ? AppColors.sky500 : AppColors.slate100,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                'Баталгаажуулах',
                size: 15,
                weight: FontWeight.w600,
                color: ink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
