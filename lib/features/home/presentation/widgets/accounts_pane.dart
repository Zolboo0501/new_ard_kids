import 'package:flutter/material.dart';

import '../../../../app/accounts.dart';
import '../../../../app/kid_profile.dart';
import '../../../../app/routes.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/account_art.dart';
import 'account_row.dart';

/// Home's Данс tab for a linked teen: every account besides the main one,
/// each opening its own screen.
class AccountsPane extends StatelessWidget {
  const AccountsPane({super.key, required this.onOpen});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (
        LineGlyph.piggy,
        Accounts.savings,
        'Хадгаламж',
        'Хуримтлал',
        Balances.savings,
        AppRoutes.savingsAccount,
      ),
      (
        LineGlyph.sprout,
        Accounts.stocks,
        'Миний өв',
        'Хөрөнгө оруулалт',
        Balances.stocks,
        AppRoutes.stocks,
      ),
      (
        LineGlyph.gift,
        Accounts.rewards,
        'Урамшуулал',
        'Оноо, урамшуулал',
        Balances.rewards,
        AppRoutes.rewardsAccount,
      ),
    ];
    return Column(
      children: [
        for (final (i, (icon, account, title, subtitle, amount, route))
            in rows.indexed) ...[
          if (i > 0) const SizedBox(height: 10),
          ListItemEntrance(
            id: title,
            index: i,
            always: true,
            delay: AppTabView.incomingDelay,
            child: AccountRow(
              icon: icon,
              image: accountSticker(account),
              title: title,
              subtitle: subtitle,
              amount: amount,
              onTap: () => onOpen(route),
            ),
          ),
        ],
      ],
    );
  }
}
