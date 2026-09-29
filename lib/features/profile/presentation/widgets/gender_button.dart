import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One option of the "Хүйс" choice: a neutral segment, outlined when picked.
class GenderButton extends StatelessWidget {
  const GenderButton({
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
          duration: const Duration(milliseconds: 160),
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.card : AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.slate900 : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: AppText(
            label,
            size: 14,
            weight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.slate900 : AppColors.slate600,
          ),
        ),
      ),
    );
  }
}
