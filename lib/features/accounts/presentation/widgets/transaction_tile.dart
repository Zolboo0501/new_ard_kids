import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/tx_item.dart';
import '../../data/units.dart';
import 'account_glyph_tile.dart';

/// One transaction row: category tile, title over subtitle and date, and the
/// signed amount. A plain row; [TransactionList] groups rows in one card.
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.item, this.unit});

  final TxItem item;

  /// The amount's unit (`койн`, `оноо`); `null` for tugrik.
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final color =
        item.amountColor ??
        (item.income ? AppColors.emerald600 : AppColors.slate900);
    final amount = item.income ? item.amount.abs() : -item.amount.abs();
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AccountGlyphTile(item.glyph, tint: item.tint, ink: item.ink),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    item.title,
                    size: 14,
                    weight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    '${item.subtitle} · ${item.when}',
                    size: 12,
                    color: AppColors.slate500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                unit == null
                    ? BalanceText(
                        amount,
                        sign: true,
                        space: false,
                        size: 14,
                        weight: FontWeight.w600,
                        color: color,
                      )
                    : Text(
                        formatUnits(amount, unit!, sign: true),
                        style: moneyStyle(
                          size: 14,
                          weight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                if (item.badge != null) ...[
                  const SizedBox(height: 4),
                  StatusBadge(label: item.badge!, tone: item.badgeTone),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
