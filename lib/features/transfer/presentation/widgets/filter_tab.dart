import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// A request-list filter: a pill with an optional count, filled in the
/// accent when selected.
class FilterTab extends StatelessWidget {
  const FilterTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = selected ? AppColors.onAccent : AppColors.slate700;
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
              color: selected ? AppColors.sky500 : AppColors.line,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                label,
                size: 13,
                weight: selected ? FontWeight.w600 : FontWeight.w500,
                color: ink,
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                AppText(
                  '$count',
                  size: 13,
                  weight: FontWeight.w600,
                  color: selected
                      ? AppColors.onAccent.withValues(alpha: 0.85)
                      : AppColors.slate500,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
