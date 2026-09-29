import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// A request-list filter: a neutral pill with an optional count.
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
    final ink = selected ? AppColors.surface : AppColors.slate700;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: withHaptic(onTap),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.slate900 : AppColors.card,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.slate900 : AppColors.line,
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
                  color: selected ? AppColors.surface : AppColors.slate500,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
