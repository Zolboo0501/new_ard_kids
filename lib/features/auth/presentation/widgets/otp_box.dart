import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/value_switcher.dart';

class OtpBox extends StatelessWidget {
  const OtpBox({super.key, required this.digit, required this.active});

  final String? digit;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 56,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: digit != null ? AppColors.dsSurfaceContainerLow : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: active
              ? AppColors.sky500.withValues(alpha: 0.4)
              : Colors.transparent,
          width: 2,
        ),
      ),
      // The digit springs in when the key is pressed, and the cursor it
      // replaces fades out under it.
      child: ValueSwitcher(
        value: digit ?? (active ? '|' : ''),
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: appEmphasizedAccelerate,
        transitionBuilder: (child, animation, _) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            // easeOutBack overshoots past 1, so the digit lands with a small
            // bounce rather than simply appearing at full size.
            scale: Tween(begin: 0.5, end: 1.0).animate(animation),
            child: child,
          ),
        ),
        child: digit != null
            ? AppText(
                digit!,
                size: 22,
                weight: FontWeight.w700,
                color: AppColors.dsPrimary,
                key: ValueKey('digit-$digit'),
              )
            : active
            ? BlinkingCursor(
                key: ValueKey('cursor'),
                color: AppColors.dsPrimary,
              )
            : const SizedBox.shrink(key: ValueKey('empty')),
      ),
    );
  }
}
