import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class RequestListSummary extends StatelessWidget {
  const RequestListSummary({
    super.key,
    required this.label,
    required this.value,
    required this.background,
    required this.color,
    this.dot,
  });

  final String label;

  /// An amount (shown with [BalanceText]) or preformatted text.
  final Object value;
  final Color background;
  final Color color;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (dot != null) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: dot,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: AppText(
                    label,
                    size: 10,
                    weight: FontWeight.w600,
                    color: AppColors.dsOnSurfaceVariant,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: switch (value) {
                final num amount => BalanceText(
                  amount,
                  animate: true,
                  space: false,
                  size: 12,
                  color: color,
                ),
                _ => Text('$value', style: moneyStyle(size: 12, color: color)),
              },
            ),
          ],
        ),
      ),
    );
  }
}
