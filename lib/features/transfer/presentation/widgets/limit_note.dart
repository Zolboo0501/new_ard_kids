import 'package:flutter/material.dart';

import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// Today's transfer limit: what is left, and a track of the daily limit
/// already used plus the [amount] being typed. Turns rose once [amount]
/// is more than what is left.
class LimitNote extends StatelessWidget {
  const LimitNote({super.key, required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    final over = amount > Limits.leftToday;
    final used = (Limits.spentToday + amount) / Limits.dailyTransfer;
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              LineIcon(
                LineGlyph.shield,
                size: 18,
                color: over ? AppColors.rose600 : AppColors.slate500,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Өнөөдөр ',
                    children: [
                      TextSpan(
                        text: formatMnt(Limits.leftToday),
                        style: moneyStyle(
                          size: 13,
                          weight: FontWeight.w600,
                          color: AppColors.slate900,
                        ),
                      ),
                      const TextSpan(text: ' шилжүүлэх боломжтой'),
                    ],
                  ),
                  style: inter(
                    size: 13,
                    weight: FontWeight.w500,
                    color: AppColors.slate700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProgressTrack(
            value: used,
            height: 6,
            color: over ? AppColors.rose500 : AppColors.sky500,
          ),
          const SizedBox(height: 6),
          AppText(
            'Өдрийн эрх ${formatMnt(Limits.dailyTransfer)} · '
            '${formatMnt(Limits.spentToday)} ашигласан',
            size: 12,
            color: AppColors.slate500,
          ),
        ],
      ),
    );
  }
}
