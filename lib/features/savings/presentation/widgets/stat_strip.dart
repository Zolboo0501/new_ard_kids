import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// Plain label / value pairs in a row, split by hairlines.
class StatStrip extends StatelessWidget {
  const StatStrip({super.key, required this.items});

  /// `(label, value, color)`; a numeric value is an amount, shown signed
  /// with [BalanceText], anything else is shown as text.
  final List<(String, Object, Color)> items;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          for (final (i, it) in items.indexed) ...[
            if (i > 0) VerticalDivider(width: 25, color: AppColors.line),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    it.$1,
                    size: 12,
                    color: AppColors.slate500,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: switch (it.$2) {
                      final num amount => BalanceText(
                        amount,
                        sign: true,
                        size: 14,
                        weight: FontWeight.w600,
                        color: it.$3,
                      ),
                      final value => Text(
                        '$value',
                        style: moneyStyle(
                          size: 14,
                          weight: FontWeight.w600,
                          color: it.$3,
                        ),
                      ),
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
