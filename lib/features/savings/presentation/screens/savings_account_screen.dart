import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/avatar.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/savings_goal.dart';
import '../widgets/goal_tile.dart';
import '../widgets/savings_account_shortcut.dart';
import '../widgets/stat_strip.dart';

/// "Хадгаламжийн данс": balance, interest summary, shortcuts and goals.
class SavingsAccountScreen extends StatelessWidget {
  const SavingsAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFAF9FF);
    void go(String r) => context.push(r);

    return Scaffold(
      backgroundColor: bg,
      appBar: const SubPageHeader(title: 'Хадгаламжийн данс', background: bg),
      body: EntranceScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            AppCard(
              radius: 24,
              padding: const EdgeInsets.all(20),
              borderColor: AppColors.slate100,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'Нийт хуримтлал',
                              size: 11,
                              weight: FontWeight.w500,
                              color: AppColors.slate400,
                            ),
                            const SizedBox(height: 2),
                            const BalanceText(
                              1280000,
                              size: 30,
                              weight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                      MascotImage(
                        asset: Stickers.piggy,
                        size: 80,
                        background: Colors.white,
                        semanticLabel: 'Гахайн сантай маскот',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const StatStrip(
                    items: [
                      ('Бодогдсон хүү', 48250, AppColors.emerald600),
                      ('Жилийн хүү', '13.5%', AppColors.slate800),
                      ('Хугацаа', '2026.12.31', AppColors.slate800),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SavingsAccountShortcut(
                  label: 'Орлого хийх',
                  asset: Stickers.jar,
                  onTap: () => go(AppRoutes.savingsDeposit),
                ),
                const SizedBox(width: 10),
                SavingsAccountShortcut(
                  label: 'Тооцоолуур',
                  asset: Stickers.calculator,
                  onTap: () => go(AppRoutes.savingsCalculator),
                ),
                const SizedBox(width: 10),
                SavingsAccountShortcut(
                  label: 'Дэлгэрэнгүй',
                  asset: Stickers.report,
                  onTap: () => go(AppRoutes.savingsHistory),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              radius: 24,
              padding: const EdgeInsets.all(16),
              borderColor: AppColors.slate100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          'Миний зорилтууд',
                          size: 14,
                          weight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                      SoftButton(
                        label: '+ Шинэ зорилт',
                        height: 30,
                        onPressed: () => go(AppRoutes.newGoal),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.slate100),
                  for (final (i, g) in kSampleGoals.indexed) ...[
                    ListItemEntrance(
                      // The title, not the goal: the list is rebuilt with new
                      // instances whenever the companion changes.
                      id: g.title,
                      index: i,
                      child: GoalTile(goal: g),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
