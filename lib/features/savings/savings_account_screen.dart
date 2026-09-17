import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

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

const kSampleGoals = [
  SavingsGoal(
    title: 'PlayStation 5 тоглоом',
    category: 'Дижитал зугаа',
    saved: 180000,
    target: 250000,
    asset: Mascots.puppyGamepad,
    tone: BadgeTone.sky,
  ),
  SavingsGoal(
    title: 'Шинэ хичээлийн ном, дэвтэр',
    category: 'Хичээл & Хөгжил',
    saved: 95000,
    target: 100000,
    asset: Mascots.bearBooks,
    tone: BadgeTone.emerald,
  ),
  SavingsGoal(
    title: 'Зуны зуслан явах сан',
    category: 'Аялал, зуслан',
    saved: 450000,
    target: 800000,
    asset: Mascots.catHeart,
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
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
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
                          Text(
                            'Нийт хуримтлал',
                            style: comfortaa(
                              size: 11,
                              weight: FontWeight.w500,
                              color: AppColors.slate400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const _BigMoney(amount: 1280000),
                        ],
                      ),
                    ),
                    const MascotImage(
                      asset: Mascots.puppyPiggy,
                      size: 80,
                      background: Colors.white,
                      semanticLabel: 'Cute mascot sticker',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const _StatStrip(
                  items: [
                    ('Бодогдсон хүү', '+₮ 48,250', AppColors.emerald600),
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
                asset: Mascots.puppyPiggy,
                onTap: () => go(AppRoutes.savingsDeposit),
              ),
              const SizedBox(width: 10),
              _Shortcut(
                label: 'Тооцоолуур',
                asset: Mascots.owlAbacus,
                onTap: () => go(AppRoutes.savingsCalculator),
              ),
              const SizedBox(width: 10),
              _Shortcut(
                label: 'Дэлгэрэнгүй',
                asset: Mascots.penguinChecklist,
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
                      child: Text(
                        'Миний зорилтууд',
                        style: comfortaa(
                          size: 14,
                          weight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
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
                for (final g in kSampleGoals) ...[
                  GoalTile(goal: g),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BigMoney extends StatelessWidget {
  const _BigMoney({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '₮',
            style: moneyStyle(
              size: 26,
              weight: FontWeight.w600,
              color: AppColors.slate700,
            ),
          ),
          TextSpan(
            text: formatMnt(amount).substring(1),
            style: moneyStyle(size: 32, letterSpacing: -0.6),
          ),
        ],
      ),
    );
  }
}

/// Three-column label/value strip on a tinted background.
class _StatStrip extends StatelessWidget {
  const _StatStrip({required this.items});

  final List<(String, String, Color)> items;

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
                    Text(
                      it.$1,
                      style: comfortaa(
                        size: 10,
                        weight: FontWeight.w500,
                        color: AppColors.slate400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(it.$2, style: moneyStyle(size: 12, color: it.$3)),
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
            Text(label, style: comfortaa(size: 12, weight: FontWeight.w700)),
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
                      child: Text(
                        goal.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: comfortaa(size: 12, weight: FontWeight.w700),
                      ),
                    ),
                    StatusBadge(
                      label: '${(goal.progress * 100).round()}%',
                      tone: goal.tone,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      goal.category,
                      style: comfortaa(
                        size: 9,
                        weight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${formatMnt(goal.saved, space: true)} / ${formatMnt(goal.target, space: true)}',
                      style: moneyStyle(size: 10, color: AppColors.slate600),
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
