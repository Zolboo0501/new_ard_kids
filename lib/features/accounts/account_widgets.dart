import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/accounts.dart';
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
    this.tint,
    this.badge,
    this.badgeTone = BadgeTone.emerald,
    this.amountColor,
  });

  final String title;
  final String subtitle;
  final String when;
  final int amount;
  final String asset;

  /// Defaults to the theme accent (`AppColors.sky50`).
  final Color? tint;
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
              BalanceText(
                item.income ? item.amount.abs() : -item.amount.abs(),
                sign: true,
                space: false,
                size: 13,
                weight: FontWeight.w500,
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

/// An account's IBAN, printed in full in blocks of four, with a button that
/// copies it without the spaces.
///
/// With [onToggleHidden] it also gets the screen's eye button, which hides
/// the number ([maskIban]) together with the balance: pass the same flag to
/// [HideableBalance].
class CopyAccountNumber extends StatelessWidget {
  const CopyAccountNumber({
    super.key,
    required this.number,
    this.prefix = '',
    this.style,
    this.hidden = false,
    this.onToggleHidden,
  });

  /// The IBAN, grouped or not (see [Accounts]).
  final String number;
  final String prefix;
  final TextStyle? style;
  final bool hidden;
  final VoidCallback? onToggleHidden;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // In a tight spot (beside a mascot) the number scales down a little
        // rather than pushing the buttons off the card.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.centerLeft,
                children: [...previous, ?current],
              ),
              child: Text(
                '$prefix${hidden ? maskIban(number) : formatIban(number)}',
                key: ValueKey(hidden),
                style:
                    style ??
                    moneyStyle(
                      size: 11,
                      weight: FontWeight.w600,
                      color: AppColors.slate400,
                    ),
              ),
            ),
          ),
        ),
        Semantics(
          button: true,
          label: 'Данс хуулах',
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
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
        if (onToggleHidden != null)
          EyeToggle(hidden: hidden, onTap: onToggleHidden!),
      ],
    );
  }
}
