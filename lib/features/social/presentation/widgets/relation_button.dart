import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One relationship choice on the add-friend screen: a line icon over a
/// label, outlined in the accent when selected.
class RelationButton extends StatelessWidget {
  const RelationButton({
    super.key,
    required this.label,
    required this.glyph,
    required this.selected,
    required this.onTap,
  });

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
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.sky50 : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.line,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              LineIcon(
                glyph,
                size: 24,
                color: selected ? AppColors.sky600 : AppColors.slate800,
              ),
              const SizedBox(height: 6),
              AppText(
                label,
                size: 13,
                weight: FontWeight.w600,
                color: selected ? AppColors.sky700 : AppColors.slate700,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
