import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/ui.dart';

class MiniStat extends StatelessWidget {
  const MiniStat({
    super.key,
    required this.asset,
    required this.label,
    required this.value,
    required this.color,
  });

  final String asset;
  final String label;

  /// Signed amount: shown as `+₮ …` or `-₮ …`.
  final num value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          MascotImage(
            asset: asset,
            size: 40,
            background: Colors.white,
            semanticLabel: label,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  size: 10,
                  weight: FontWeight.w500,
                  color: AppColors.slate400,
                ),
                FittedBox(
                  child: BalanceText(
                    value,
                    sign: true,
                    space: false,
                    size: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
