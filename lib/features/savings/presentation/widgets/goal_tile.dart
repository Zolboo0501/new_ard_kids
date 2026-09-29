import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/savings_goal.dart';

/// Goal card with category chip, amounts and progress bar.
class GoalTile extends StatelessWidget {
  const GoalTile({super.key, required this.goal});

  final SavingsGoal goal;

  @override
  Widget build(BuildContext context) {
    final (_, fg, _) = goal.tone.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          MascotTile(
            asset: goal.asset,
            size: 56,
            background: AppColors.card,
            label: goal.title,
          ),
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
                        size: 12,
                        weight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusBadge(
                      label: '${(goal.progress * 100).round()}%',
                      tone: goal.tone,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Category left, "saved / target" right; the amounts drop to
                // their own line when both don't fit.
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    AppText(
                      goal.category,
                      size: 9,
                      weight: FontWeight.w600,
                      color: fg,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BalanceText(
                            goal.saved,
                            space: false,
                            size: 10,
                            color: AppColors.slate600,
                            decimals: false,
                          ),
                          Text(
                            ' / ',
                            style: moneyStyle(
                              size: 10,
                              color: AppColors.slate600,
                            ),
                          ),
                          BalanceText(
                            goal.target,
                            space: false,
                            size: 10,
                            color: AppColors.slate600,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ProgressTrack(value: goal.progress),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
