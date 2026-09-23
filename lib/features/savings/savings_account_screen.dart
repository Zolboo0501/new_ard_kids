import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';
import '../../widgets/entrance.dart';
import '../../app/avatar.dart';

/// Savings goal shown on the savings screens.
class SavingsGoal {
  const SavingsGoal({
    required this.title,
    required this.category,
    required this.saved,
    required this.target,
    required this.asset,
    required this.tone,
  });

  final String title;
  final String category;
  final int saved;
  final int target;
  final String asset;
  final BadgeTone tone;

  double get progress => target == 0 ? 0 : saved / target;
}

/// Sample goals, pictured with the chosen companion's stickers.
List<SavingsGoal> get kSampleGoals => [
  SavingsGoal(
    title: 'PlayStation 5 тоглоом',
    category: 'Дижитал зугаа',
    saved: 180000,
    target: 250000,
    asset: Stickers.games,
    tone: BadgeTone.sky,
  ),
  SavingsGoal(
    title: 'Шинэ хичээлийн ном, дэвтэр',
    category: 'Хичээл & Хөгжил',
    saved: 95000,
    target: 100000,
    asset: Stickers.books,
    tone: BadgeTone.emerald,
  ),
  SavingsGoal(
    title: 'Зуны зуслан явах сан',
    category: 'Аялал, зуслан',
    saved: 450000,
    target: 800000,
    asset: Stickers.travel,
    tone: BadgeTone.amber,
  ),
];

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
                  const _StatStrip(
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
                _Shortcut(
                  label: 'Орлого хийх',
                  asset: Stickers.jar,
                  onTap: () => go(AppRoutes.savingsDeposit),
                ),
                const SizedBox(width: 10),
                _Shortcut(
                  label: 'Тооцоолуур',
                  asset: Stickers.calculator,
                  onTap: () => go(AppRoutes.savingsCalculator),
                ),
                const SizedBox(width: 10),
                _Shortcut(
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

class _StatStrip extends StatelessWidget {
  const _StatStrip({required this.items});

  /// `(label, value, color)`; a numeric value is an amount, shown signed
  /// with [BalanceText], anything else is shown as text.
  final List<(String, Object, Color)> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.slate50.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (final (i, it) in items.indexed) ...[
              if (i > 0)
                VerticalDivider(
                  width: 1,
                  color: AppColors.slate200.withValues(alpha: 0.7),
                ),
              Expanded(
                child: Column(
                  children: [
                    AppText(
                      it.$1,
                      size: 10,
                      weight: FontWeight.w500,
                      color: AppColors.slate400,
                    ),
                    const SizedBox(height: 2),
                    switch (it.$2) {
                      final num amount => BalanceText(
                        amount,
                        sign: true,
                        size: 12,
                        color: it.$3,
                      ),
                      final value => Text(
                        '$value',
                        style: moneyStyle(size: 12, color: it.$3),
                      ),
                    },
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.label,
    required this.asset,
    required this.onTap,
  });

  final String label;
  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        radius: 20,
        padding: const EdgeInsets.symmetric(vertical: 12),
        borderColor: AppColors.slate100,
        onTap: onTap,
        child: Column(
          children: [
            MascotImage(
              asset: asset,
              size: 56,
              background: Colors.white,
              semanticLabel: label,
            ),
            const SizedBox(height: 4),
            AppText(label, size: 12, weight: FontWeight.w700),
          ],
        ),
      ),
    );
  }
}

/// Goal card with category chip, amounts and progress bar.
class GoalTile extends StatelessWidget {
  const GoalTile({super.key, required this.goal});

  final SavingsGoal goal;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = goal.tone.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          MascotTile(
            asset: goal.asset,
            size: 56,
            border: AppColors.slate100,
            label: goal.title,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        goal.title,
                        size: 12,
                        weight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusBadge(
                      label: '${(goal.progress * 100).round()}%',
                      tone: goal.tone,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Category left, "saved / target" right; the amounts drop to
                // their own line when both don't fit.
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    AppText(
                      goal.category,
                      size: 9,
                      weight: FontWeight.w600,
                      color: fg,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BalanceText(
                            goal.saved,
                            space: false,
                            size: 10,
                            color: AppColors.slate600,
                            decimals: false,
                          ),
                          Text(
                            ' / ',
                            style: moneyStyle(
                              size: 10,
                              color: AppColors.slate600,
                            ),
                          ),
                          BalanceText(
                            goal.target,
                            space: false,
                            size: 10,
                            color: AppColors.slate600,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ProgressTrack(value: goal.progress),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
