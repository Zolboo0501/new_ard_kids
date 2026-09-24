import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class StatStrip extends StatelessWidget {
  const StatStrip({super.key, required this.items});

  /// `(label, value, color)`; a numeric value is an amount, shown signed
  /// with [BalanceText], anything else is shown as text.
  final List<(String, Object, Color)> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.slate50.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (final (i, it) in items.indexed) ...[
              if (i > 0)
                VerticalDivider(
                  width: 1,
                  color: AppColors.slate200.withValues(alpha: 0.7),
                ),
              Expanded(
                child: Column(
                  children: [
                    AppText(
                      it.$1,
                      size: 10,
                      weight: FontWeight.w500,
                      color: AppColors.slate400,
                    ),
                    const SizedBox(height: 2),
                    switch (it.$2) {
                      final num amount => BalanceText(
                        amount,
                        sign: true,
                        size: 12,
                        color: it.$3,
                      ),
                      final value => Text(
                        '$value',
                        style: moneyStyle(size: 12, color: it.$3),
                      ),
                    },
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
