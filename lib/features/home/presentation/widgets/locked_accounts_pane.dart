import 'package:flutter/material.dart';

import '../../../../app/accounts.dart';
import '../../../../app/kid_profile.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import 'account_row.dart';
import 'home_link_prompt.dart';

/// Home's Данс tab before a parent is linked: the one link prompt, the
/// accounts that already work, and the ones linking opens, each with a
/// small lock.
class LockedAccountsPane extends StatelessWidget {
  const LockedAccountsPane({super.key, required this.onLink});

  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    const locked = 'Эцэг эх холбосны дараа';
    final items = <(Object, Widget)>[
      (#linkPrompt, HomeLinkPrompt(onLink: onLink)),
      (
        'Харилцах данс',
        AccountRow(
          icon: LineGlyph.pocket,
          title: 'Харилцах данс',
          subtitle: formatIban(Accounts.main),
          amount: Balances.main,
        ),
      ),
      (
        'Урамшуулал',
        const AccountRow(
          icon: LineGlyph.gift,
          title: 'Урамшуулал',
          subtitle: 'Оноо, урамшуулал',
          amount: Balances.rewards,
        ),
      ),
      (
        'Хадгаламж',
        const AccountRow(
          icon: LineGlyph.piggy,
          title: 'Хадгаламж',
          subtitle: locked,
          locked: true,
        ),
      ),
      (
        'Миний өв',
        const AccountRow(
          icon: LineGlyph.sprout,
          title: 'Миний өв',
          subtitle: locked,
          locked: true,
        ),
      ),
      (
        'Ард койн',
        const AccountRow(
          icon: LineGlyph.ardCoin,
          title: 'Ард койн',
          subtitle: locked,
          locked: true,
        ),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, (id, child)) in items.indexed) ...[
          if (i > 0) SizedBox(height: i == 1 ? 16 : 10),
          ListItemEntrance(
            id: id,
            index: i,
            always: true,
            delay: AppTabView.incomingDelay,
            child: child,
          ),
        ],
      ],
    );
  }
}
