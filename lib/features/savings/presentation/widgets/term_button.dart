import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class TermButton extends StatelessWidget {
  const TermButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: withHaptic(onTap),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.sky50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.slate200,
              width: selected ? 2 : 1,
            ),
          ),
          child: AppText(
            label,
            size: 12,
            weight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? AppColors.sky700 : AppColors.slate600,
          ),
        ),
      ),
    );
  }
}
