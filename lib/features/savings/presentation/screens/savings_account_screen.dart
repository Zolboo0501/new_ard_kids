import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/accounts.dart';
import '../../../../app/kid_profile.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
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
    final bg = AppColors.surface;
    void go(String r) => context.push(r);

    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(title: 'Хадгаламжийн данс', background: bg),
      body: EntranceScope(
        // Split on wide windows: the balance and actions beside the goals.
        child: AdaptiveSplit(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          gap: 16,
          leading: [
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Нийт хуримтлал',
                    size: 13,
                    weight: FontWeight.w500,
                    color: AppColors.slate500,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: BalanceText(
                      Balances.savings,
                      size: 40,
                      weight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    maskIban(Accounts.savings),
                    style: moneyStyle(size: 13, color: AppColors.slate500),
                  ),
                  Divider(height: 32, color: AppColors.line),
                  StatStrip(
                    items: [
                      ('Бодогдсон хүү', 48250, AppColors.emerald600),
                      ('Жилийн хүү', '13.5%', AppColors.slate900),
                      ('Дуусах огноо', '2026.12.31', AppColors.slate900),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SavingsAccountShortcut(
                  label: 'Орлого хийх',
                  glyph: LineGlyph.plus,
                  onTap: () => go(AppRoutes.savingsDeposit),
                ),
                const SizedBox(width: 8),
                SavingsAccountShortcut(
                  label: 'Тооцоолуур',
                  glyph: LineGlyph.calculator,
                  onTap: () => go(AppRoutes.savingsCalculator),
                ),
                const SizedBox(width: 8),
                SavingsAccountShortcut(
                  label: 'Түүх',
                  glyph: LineGlyph.history,
                  onTap: () => go(AppRoutes.savingsHistory),
                ),
              ],
            ),
          ],
          trailing: [
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          'Миний зорилтууд',
                          size: 16,
                          weight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Шинэ зорилт нэмэх',
                        excludeSemantics: true,
                        child: Pressable(
                          onTap: () => go(AppRoutes.newGoal),
                          child: SizedBox(
                            height: 44,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LineIcon(
                                  LineGlyph.plus,
                                  size: 18,
                                  color: AppColors.sky600,
                                ),
                                const SizedBox(width: 4),
                                AppText(
                                  'Шинэ зорилт',
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: AppColors.sky600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (final (i, g) in kSampleGoals.indexed) ...[
                    if (i > 0) Divider(height: 1, color: AppColors.line),
                    ListItemEntrance(
                      id: g.title,
                      index: i,
                      child: GoalTile(goal: g),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
