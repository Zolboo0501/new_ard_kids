import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// Ээж / Аав choice on [ParentLinkScreen]: a plain 48pt segment with an
/// accent outline when selected.
class RoleButton extends StatelessWidget {
  const RoleButton({
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
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.sky50 : AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: AppText(
            label,
            size: 15,
            weight: FontWeight.w600,
            color: selected ? AppColors.sky700 : AppColors.slate600,
          ),
        ),
      ),
    );
  }
}
