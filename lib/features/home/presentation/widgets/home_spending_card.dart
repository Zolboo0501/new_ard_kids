import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// "Энэ 7 хоногийн зарлага", compact: the week's total with how it
/// compares to last week, a short soft bar per day (today in the accent),
/// and what the money went on. Pastel tracks and fills from the theme's
/// accent, on a white card.
class HomeSpendingCard extends StatelessWidget {
  const HomeSpendingCard({
    super.key,
    required this.days,
    required this.dayLabels,
    required this.today,
    required this.lastWeek,
    required this.categories,
  });

  /// One amount per day, Monday first.
  final List<int> days;
  final List<String> dayLabels;

  /// Today's index in [days] (0 = Monday).
  final int today;

  /// Last week's total.
  final int lastWeek;

  /// This week's spending by kind: label and amount.
  final List<(String, int)> categories;

  static const _barHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    final total = days.fold(0, (a, b) => a + b);
    final peak = days.fold(1, (a, b) => a > b ? a : b);
    final change = lastWeek == 0 ? 0 : ((total - lastWeek) / lastWeek * 100);
    final less = change <= 0;
    final shades = [AppColors.sky500, AppColors.sky300, AppColors.sky200];
    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The title over the total on the left, the change on the right.
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Энэ 7 хоногийн зарлага',
                      size: 12,
                      weight: FontWeight.w600,
                      color: AppColors.slate500,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        formatMnt(total),
                        size: 20,
                        weight: FontWeight.w700,
                        color: AppColors.slate900,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Spending less than last week is the good news here.
              Semantics(
                label:
                    'Өмнөх 7 хоногоос ${change.abs().round()}% '
                    '${less ? 'бага' : 'их'}',
                excludeSemantics: true,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
                  decoration: BoxDecoration(
                    color: less ? AppColors.emerald50 : AppColors.rose50,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.rotate(
                        angle: less ? 1.5708 : -1.5708,
                        child: LineIcon(
                          LineGlyph.arrowRight,
                          size: 14,
                          color: less
                              ? AppColors.emerald600
                              : AppColors.rose600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      AppText(
                        '${change.abs().round()}%',
                        size: 12,
                        weight: FontWeight.w700,
                        color: less ? AppColors.emerald700 : AppColors.rose600,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // A soft track per day with the day's share filled in.
          Semantics(
            label: [
              for (final (i, d) in days.indexed)
                '${dayLabels[i]} ${formatMnt(d)}',
            ].join(', '),
            excludeSemantics: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (i, amount) in days.indexed)
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 14,
                          height: _barHeight,
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                            color: AppColors.sky50,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Container(
                            height: (_barHeight * amount / peak).clamp(
                              8.0,
                              _barHeight,
                            ),
                            decoration: BoxDecoration(
                              color: i == today
                                  ? AppColors.sky500
                                  : AppColors.sky200,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        AppText(
                          dayLabels[i],
                          size: 11,
                          weight: i == today
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: i == today
                              ? AppColors.slate900
                              : AppColors.slate500,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final (i, (label, amount)) in categories.indexed)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: shades[i % shades.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: AppText(
                              label,
                              size: 11,
                              color: AppColors.slate500,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      AppText(
                        formatMnt(amount),
                        size: 13,
                        weight: FontWeight.w700,
                        color: AppColors.slate900,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
