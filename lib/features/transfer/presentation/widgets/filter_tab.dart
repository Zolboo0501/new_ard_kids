import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class FilterTab extends StatelessWidget {
  const FilterTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.tone,
  });

  final String label;
  final int? count;
  final BadgeTone? tone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = tone?.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: withHaptic(onTap),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.sky500 : AppColors.card,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.card,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (colors != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.onAccent : colors.$2,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              AppText(
                label,
                size: 12,
                weight: FontWeight.w700,
                color: selected ? AppColors.onAccent : AppColors.slate700,
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.onAccent.withValues(alpha: 0.15)
                        : colors!.$1,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: AppText(
                    '$count',
                    size: 10,
                    weight: FontWeight.w700,
                    color: selected ? AppColors.onAccent : colors!.$2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
