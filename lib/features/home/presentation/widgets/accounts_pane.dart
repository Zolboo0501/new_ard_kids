import 'package:flutter/material.dart';

import '../../../../app/avatar.dart';
import '../../../../app/routes.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/entrance.dart';
import 'account_row.dart';

class AccountsPane extends StatelessWidget {
  const AccountsPane({super.key, required this.avatar, required this.onOpen});

  final AppAvatar avatar;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListItemEntrance(
          id: 'Хадгаламж',
          index: 0,
          always: true,
          delay: AppTabView.incomingDelay,
          child: AccountRow(
            title: 'Хадгаламж',
            subtitle: 'Хуримтлал үүсгээрэй',
            mascot: avatar.savings,
            amount: 1280000,
            onTap: () => onOpen(AppRoutes.savingsAccount),
          ),
        ),
        const SizedBox(height: 10),
        ListItemEntrance(
          id: 'Миний өв',
          index: 1,
          always: true,
          delay: AppTabView.incomingDelay,
          child: AccountRow(
            title: 'Миний өв',
            subtitle: 'Хөрөнгө оруулалтаа хараарай',
            mascot: avatar.stocks,
            amount: 142500,
            onTap: () => onOpen(AppRoutes.stocks),
          ),
        ),
        const SizedBox(height: 10),
        ListItemEntrance(
          id: 'Урамшуулал',
          index: 2,
          always: true,
          delay: AppTabView.incomingDelay,
          child: AccountRow(
            title: 'Урамшуулал',
            subtitle: 'Оноогоо хараарай',
            mascot: avatar.rewards,
            amount: 35000,
            onTap: () => onOpen(AppRoutes.rewardsAccount),
          ),
        ),
        const SizedBox(height: 10),
        // ListItemEntrance(
        //   id: 'Ард койны данс',
        //   index: 3,
        //   always: true,
        //   delay: AppTabView.incomingDelay,
        //   child: AccountRow(
        //     title: 'Ард койны данс',
        //     subtitle: 'MN 5049 8219 04',
        //     mascot: Mascots.bunnyCoin,
        //     tileColor: AppColors.amber50,
        //     amount: 50000,
        //     badge: Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        //       decoration: BoxDecoration(
        //         color: AppColors.amber500.withValues(alpha: 0.1),
        //         borderRadius: BorderRadius.circular(4),
        //         border: Border.all(color: AppColors.amber200),
        //       ),
        //       child: AppText(
        //         '1 Койн = 1₮',
        //         size: 9,
        //         weight: FontWeight.w700,
        //         color: AppColors.amber600,
        //       ),
        //     ),
        //     onTap: () => onOpen(AppRoutes.coinAccount),
        //   ),
        // ),
      ],
    );
  }
}
