import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';

/// One row in an account's transaction list.
class TxItem {
  const TxItem({
    required this.title,
    required this.subtitle,
    required this.when,
    required this.amount,
    required this.asset,
    this.tint = AppColors.sky50,
    this.badge,
    this.badgeTone = BadgeTone.emerald,
    this.amountColor,
  });

  final String title;
  final String subtitle;
  final String when;
  final int amount;
  final String asset;
  final Color tint;
  final String? badge;
  final BadgeTone badgeTone;
  final Color? amountColor;

  bool get income => amount >= 0;
}

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
            background: item.tint,
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
                    AppText(item.title, size: 12, weight: FontWeight.w700),
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
              Text(
                '${item.income ? '+' : '-'}${formatMnt(item.amount.abs(), space: true)}',
                style: moneyStyle(
                  size: 13,
                  weight: FontWeight.w800,
                  color: color,
                ),
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

/// Account number with a copy button.
class CopyAccountNumber extends StatelessWidget {
  const CopyAccountNumber({
    super.key,
    required this.number,
    this.prefix = '',
    this.style,
  });

  final String number;
  final String prefix;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$prefix$number',
          style:
              style ??
              comfortaa(
                size: 11,
                weight: FontWeight.w600,
                color: AppColors.slate400,
              ),
        ),
        Semantics(
          button: true,
          label: 'Данс хуулах',
          child: GestureDetector(
            onTap: () {
              Clipboard.setData(
                ClipboardData(text: number.replaceAll(' ', '')),
              );
              showAppSnack(context, 'Дансны дугаар хуулагдлаа');
            },
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.content_copy_rounded,
                size: 14,
                color: AppColors.slate400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
