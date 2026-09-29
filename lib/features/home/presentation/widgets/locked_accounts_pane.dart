import 'package:flutter/material.dart';

import '../../../../app/accounts.dart';
import '../../../../app/avatar.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import 'account_row.dart';

class LockedAccountsPane extends StatelessWidget {
  const LockedAccountsPane({
    super.key,
    required this.avatar,
    required this.onLink,
  });

  final AppAvatar avatar;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    Widget linkButton() => GestureDetector(
      onTap: withHaptic(onLink),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.sky500,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AppText(
          'Эцэг эх холбох',
          size: 10.5,
          weight: FontWeight.w700,
          color: AppColors.onAccent,
        ),
      ),
    );

    Widget status(num amount, String label, Color amountColor, Color c) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            BalanceText(amount, size: 13, color: amountColor),
            const SizedBox(height: 2),
            AppText(label, size: 9, weight: FontWeight.w700, color: c),
          ],
        );

    return Column(
      children: [
        ListItemEntrance(
          id: 'Халаасны үндсэн данс',
          index: 0,
          always: true,
          delay: AppTabView.incomingDelay,
          child: AccountRow(
            icon: LineGlyph.pocket,
            title: 'Халаасны үндсэн данс',
            subtitle: formatIban(Accounts.main),
            mascot: avatar.pick,
            tileColor: AppColors.sky50,
            trailing: status(20000, '● Идэвхтэй', Night.text, AppColors.sky500),
          ),
        ),
        const SizedBox(height: 10),
        ListItemEntrance(
          id: 'Хадгаламжийн данс',
          index: 1,
          always: true,
          delay: AppTabView.incomingDelay,
          child: AccountRow(
            icon: LineGlyph.piggy,
            title: 'Хадгаламжийн данс',
            subtitle: 'Холболт шаардлагатай',
            mascot: avatar.savings,
            tileColor: AppColors.amber50,
            locked: true,
            trailing: linkButton(),
          ),
        ),
        const SizedBox(height: 10),
        ListItemEntrance(
          id: 'Хувьцаа данс',
          index: 2,
          always: true,
          delay: AppTabView.incomingDelay,
          child: AccountRow(
            icon: LineGlyph.sprout,
            title: 'Хувьцаа данс',
            subtitle: formatIban(Accounts.stocks),
            mascot: avatar.stocks,
            tileColor: AppColors.sky50,
            locked: true,
            trailing: linkButton(),
          ),
        ),
        const SizedBox(height: 10),
        ListItemEntrance(
          id: 'Урамшууллын данс',
          index: 3,
          always: true,
          delay: AppTabView.incomingDelay,
          child: AccountRow(
            icon: LineGlyph.gift,
            title: 'Урамшууллын данс',
            subtitle: 'Эхлэлийн урамшуулал',
            mascot: avatar.rewards,
            tileColor: AppColors.amber50,
            trailing: status(10000, 'Идэвхтэй', Night.amber, Night.text2),
          ),
        ),
        const SizedBox(height: 10),
        ListItemEntrance(
          id: 'Койны данс',
          index: 4,
          always: true,
          delay: AppTabView.incomingDelay,
          child: AccountRow(
            title: 'Койны данс',
            subtitle: formatIban(Accounts.coin),
            mascot: Mascots.ardCoin3d,
            tileColor: AppColors.amber50,
            locked: true,
            trailing: linkButton(),
          ),
        ),
      ],
    );
  }
}
