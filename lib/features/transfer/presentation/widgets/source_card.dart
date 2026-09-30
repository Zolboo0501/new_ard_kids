import 'package:flutter/material.dart';

import '../../../../app/accounts.dart';
import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import 'limit_note.dart';

/// The account money leaves from: its available balance, the screen's
/// largest figure, and today's limit against the [amount] being sent.
class SourceCard extends StatelessWidget {
  const SourceCard({super.key, required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    final iban = Accounts.main;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            'Боломжит үлдэгдэл',
            size: 13,
            weight: FontWeight.w500,
            color: AppColors.slate500,
          ),
          const SizedBox(height: 4),
          // Left-aligned, under the label: the card's right side is where
          // the character's sticker stands (see AvatarCardArt).
          Align(
            alignment: Alignment.centerLeft,
            child: BalanceText(
              Balances.main,
              size: 36,
              color: AppColors.slate900,
              weight: FontWeight.w600,
              currencyWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          AppText(
            'Үндсэн данс ••${iban.substring(iban.length - 4)}',
            size: 12,
            color: AppColors.slate500,
          ),
          Divider(height: 28, color: AppColors.line),
          LimitNote(amount: amount),
        ],
      ),
    );
  }
}
