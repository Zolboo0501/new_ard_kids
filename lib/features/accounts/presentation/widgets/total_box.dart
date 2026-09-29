import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// The amount to pay at the foot of an order: a hairline, then the label
/// (with a secondary line) beside the total.
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
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(label, size: 14, weight: FontWeight.w600),
                const SizedBox(height: 2),
                AppText(sub, size: 12, color: AppColors.slate500),
              ],
            ),
          ),
          BalanceText(
            total,
            animate: true,
            size: 22,
            weight: FontWeight.w600,
            color: AppColors.slate900,
          ),
        ],
      ),
    );
  }
}
