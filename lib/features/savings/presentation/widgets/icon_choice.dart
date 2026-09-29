import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';

/// A selectable goal icon: a line glyph on a rounded tile.
class IconChoice extends StatelessWidget {
  const IconChoice({
    super.key,
    required this.label,
    required this.glyph,
    required this.selected,
    required this.onTap,
  });

  /// Read by screen readers only.
  final String label;
  final LineGlyph glyph;
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
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.sky50 : AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.slate50,
              width: 1.5,
            ),
          ),
          child: LineIcon(
            glyph,
            size: 24,
            color: selected ? AppColors.sky600 : AppColors.slate800,
          ),
        ),
      ),
    );
  }
}
