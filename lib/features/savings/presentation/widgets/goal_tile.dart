import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/savings_goal.dart';
import 'savings_glyph_tile.dart';

/// A goal row: glyph tile, title, saved / target and a progress bar.
class GoalTile extends StatelessWidget {
  const GoalTile({super.key, required this.goal});

  final SavingsGoal goal;

  @override
  Widget build(BuildContext context) {
    final percent = (goal.progress * 100).round();
    final done = goal.progress >= 1;
    return Semantics(
      label:
          '${goal.title}, ${formatMnt(goal.saved)} / ${formatMnt(goal.target)}, '
          '$percent%',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SavingsGlyphTile(glyph: goal.glyph, tone: goal.tone),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          goal.title,
                          size: 15,
                          weight: FontWeight.w600,
                          color: AppColors.slate900,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$percent%',
                        style: moneyStyle(
                          size: 13,
                          weight: FontWeight.w600,
                          color: done
                              ? AppColors.emerald600
                              : AppColors.slate600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  AppText(goal.category, size: 13, color: AppColors.slate500),
                  const SizedBox(height: 10),
                  ProgressTrack(
                    value: goal.progress,
                    height: 6,
                    color: done ? AppColors.emerald500 : AppColors.sky500,
                    track: AppColors.slate100,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      BalanceText(
                        goal.saved,
                        space: false,
                        size: 13,
                        weight: FontWeight.w600,
                        color: AppColors.slate900,
                      ),
                      const Spacer(),
                      AppText('Зорилт ', size: 13, color: AppColors.slate500),
                      BalanceText(
                        goal.target,
                        space: false,
                        size: 13,
                        color: AppColors.slate500,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
