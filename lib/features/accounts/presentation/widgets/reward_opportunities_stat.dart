import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class RewardOpportunitiesStat extends StatelessWidget {
  const RewardOpportunitiesStat({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;

  /// An amount (shown signed with [BalanceText]) or preformatted text.
  final Object value;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (_, fg, _) = tone.colors;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: fg.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: fg),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  size: 10,
                  weight: FontWeight.w600,
                  color: tone == BadgeTone.amber ? fg : AppColors.slate400,
                ),
                FittedBox(
                  child: switch (value) {
                    final num amount => BalanceText(
                      amount,
                      animate: true,
                      sign: true,
                      space: false,
                      size: 13,
                      weight: FontWeight.w800,
                      color: fg,
                    ),
                    _ => Text(
                      '$value',
                      style: moneyStyle(
                        size: 13,
                        weight: FontWeight.w800,
                        color: fg,
                      ),
                    ),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
