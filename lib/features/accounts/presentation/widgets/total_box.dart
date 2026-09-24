import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class TotalBox extends StatelessWidget {
  const TotalBox({
    super.key,
    required this.label,
    required this.sub,
    required this.total,
  });

  final String label;
  final String sub;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sky50.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  size: 11,
                  weight: FontWeight.w500,
                  color: AppColors.sky900,
                ),
                AppText(sub, size: 9, color: AppColors.sky600),
              ],
            ),
          ),
          BalanceText(
            total,
            animate: true,
            space: false,
            size: 18,
            weight: FontWeight.w600,
            color: AppColors.sky700,
          ),
        ],
      ),
    );
  }
}
