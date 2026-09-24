import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/tx_item.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.item,
    this.whenBelow = false,
  });

  final TxItem item;

  /// Shows the date under the amount instead of after the subtitle.
  final bool whenBelow;

  @override
  Widget build(BuildContext context) {
    final color =
        item.amountColor ??
        (item.income ? AppColors.emerald600 : AppColors.rose600);
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          MascotTile(
            asset: item.asset,
            background: item.tint ?? AppColors.sky50,
            radius: 14,
            label: item.title,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppText(item.title, size: 12, weight: FontWeight.w500),
                    if (item.badge != null && !whenBelow)
                      StatusBadge(label: item.badge!, tone: item.badgeTone),
                  ],
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppText(
                      whenBelow
                          ? item.subtitle
                          : '${item.subtitle}  •  ${item.when}',
                      size: 10,
                      color: AppColors.slate400,
                    ),
                    if (item.badge != null && whenBelow)
                      StatusBadge(label: item.badge!, tone: item.badgeTone),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BalanceText(
                item.income ? item.amount.abs() : -item.amount.abs(),
                sign: true,
                space: false,
                size: 13,
                weight: FontWeight.w600,
                color: color,
              ),
              if (whenBelow)
                AppText(item.when, size: 9, color: AppColors.slate400),
            ],
          ),
        ],
      ),
    );
  }
}
