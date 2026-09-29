import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';

class QuickButton extends StatelessWidget {
  const QuickButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _duration;
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        scale: 0.94,
        // Fill, border and text colour ease to the selected look; the chip
        // also lifts slightly so the change reads as a selection.
        child: AnimatedScale(
          scale: selected ? 1.04 : 1,
          duration: duration,
          curve: appEmphasizedDecelerate,
          child: AnimatedContainer(
            duration: duration,
            curve: appEmphasizedDecelerate,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.sky50 : AppColors.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.sky500 : AppColors.slate50,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: AnimatedDefaultTextStyle(
              duration: duration,
              curve: appEmphasizedDecelerate,
              style: inter(
                size: 13,
                weight: FontWeight.w600,
                color: selected ? AppColors.sky700 : AppColors.slate700,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
