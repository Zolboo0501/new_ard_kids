import 'package:flutter/material.dart';

import '../../../../app/accounts.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// The [amount] typed on the amount screen, and the main account it leaves
/// (or, for a money request, reaches).
class SourceCard extends StatelessWidget {
  const SourceCard({
    super.key,
    required this.amount,
    this.label = 'Илгээх дүн',
  });

  final int amount;
  final String label;

  @override
  Widget build(BuildContext context) {
    final iban = Accounts.main;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            label,
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
              amount,
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
        ],
      ),
    );
  }
}
