import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class PriceRow extends StatelessWidget {
  const PriceRow(this.label, this.value, {super.key});

  final String label;

  /// An amount (shown with [BalanceText]) or text such as `ҮНЭГҮЙ`.
  final Object value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: AppText(label, size: 12, color: AppColors.slate600)),
          switch (value) {
            final num amount => BalanceText(
              amount,
              space: false,
              size: 12,
              weight: FontWeight.w600,
            ),
            _ => Text(
              '$value',
              style: moneyStyle(
                size: 12,
                weight: FontWeight.w600,
                color: AppColors.slate800,
              ),
            ),
          },
        ],
      ),
    );
  }
}
