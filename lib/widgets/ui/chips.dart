/// Chips and badges.
library;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../app_text.dart';
import 'interaction.dart';
import 'money.dart';
import 'mascots.dart';

/// Small filter chip (filled when selected).
class FilterChipPill extends StatelessWidget {
  const FilterChipPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.mascot,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  /// A [Mascots] asset shown before the label, in place of an emoji.
  final String? mascot;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: withHaptic(onTap),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: selected ? AppColors.surface : AppColors.slate500,
                ),
                const SizedBox(width: 4),
              ],
              if (mascot != null) ...[
                MascotIcon(mascot!, size: 18),
                const SizedBox(width: 5),
              ],
              AppText(
                label,
                size: 13,
                weight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.surface : AppColors.slate600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tinted status badge ("Идэвхтэй", "Хүлээгдэж буй", ...).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.sky,
    this.icon,
    this.dot = false,
  });

  final String label;
  final BadgeTone tone;
  final IconData? icon;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = tone.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 3),
          ],
          AppText(label, size: 12, weight: FontWeight.w600, color: fg),
        ],
      ),
    );
  }
}

enum BadgeTone {
  sky,
  emerald,
  amber,
  rose,
  slate;

  (Color, Color, Color) get colors => switch (this) {
    BadgeTone.sky => (AppColors.sky50, AppColors.sky600, AppColors.sky100),
    BadgeTone.emerald => (
      AppColors.emerald50,
      AppColors.emerald600,
      AppColors.emerald100,
    ),
    BadgeTone.amber => (
      AppColors.amber50,
      AppColors.amber600,
      AppColors.amber200,
    ),
    BadgeTone.rose => (AppColors.rose50, AppColors.rose600, AppColors.rose100),
    BadgeTone.slate => (
      AppColors.slate100,
      AppColors.slate500,
      AppColors.slate200,
    ),
  };
}

/// Row of quick amount chips (`+₮10,000`, ...).
class QuickAmountChips extends StatelessWidget {
  const QuickAmountChips({
    super.key,
    required this.amounts,
    required this.onSelected,
    this.selected,
    this.additive = true,
  });

  final List<int> amounts;
  final ValueChanged<int> onSelected;
  final int? selected;
  final bool additive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < amounts.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onTap: withHaptic(() => onSelected(amounts[i])),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected == amounts[i]
                      ? AppColors.slate900
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected == amounts[i]
                        ? AppColors.slate900
                        : AppColors.line,
                  ),
                ),
                child: FittedBox(
                  child: AppText(
                    additive ? '+${_short(amounts[i])}' : formatMnt(amounts[i]),
                    size: 13,
                    weight: FontWeight.w600,
                    color: selected == amounts[i]
                        ? AppColors.surface
                        : AppColors.slate800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  static String _short(int v) => v >= 1000 && v % 1000 == 0
      ? '${formatMnt(v ~/ 1000).substring(1)}k'
      : formatMnt(v);
}
