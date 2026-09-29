import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../../../app/age_group.dart';

/// One age range on "Насаа сонгох": the range set large, its school stage
/// underneath, and a radio mark. The whole row is the touch target.
class AgeGroupOption extends StatelessWidget {
  const AgeGroupOption({
    super.key,
    required this.group,
    required this.selected,
    required this.onTap,
  });

  final AgeGroup group;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.sky500;
    return Semantics(
      button: true,
      selected: selected,
      label: '${group.label}, ${group.hint}',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.98,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? accent : AppColors.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      group.label,
                      size: 20,
                      weight: FontWeight.w700,
                      color: AppColors.slate900,
                      letterSpacing: -0.3,
                    ),
                    const SizedBox(height: 2),
                    AppText(group.hint, size: 13, color: AppColors.slate500),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? accent : Colors.transparent,
                  border: Border.all(
                    color: selected ? accent : AppColors.slate300,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? LineIcon(
                        LineGlyph.check,
                        size: 16,
                        stroke: 2.2,
                        color: AppColors.onAccent,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
