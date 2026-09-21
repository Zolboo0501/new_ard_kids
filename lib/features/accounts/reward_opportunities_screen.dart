import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';
import '../../widgets/entrance.dart';

/// "Урамшуулал авах боломжууд": ways to earn reward points.
class RewardOpportunitiesScreen extends StatefulWidget {
  const RewardOpportunitiesScreen({super.key});

  @override
  State<RewardOpportunitiesScreen> createState() =>
      _RewardOpportunitiesScreenState();
}

class _RewardOpportunitiesScreenState extends State<RewardOpportunitiesScreen> {
  bool _dailyClaimed = false;

  @override
  Widget build(BuildContext context) {
    void go(String r) => context.push(r);

    final tasks = [
      (
        'Найзаа урих',
        Mascots.foxWave,
        5000,
        AppColors.amber600,
        ('Хялбар', BadgeTone.amber),
        'Урих',
        false,
        () => go(AppRoutes.inviteFriends),
      ),
      (
        'Хадгаламжийн зорилгодоо хүрэх',
        Mascots.puppyPiggy,
        15000,
        AppColors.sky600,
        ('Тусгай', BadgeTone.sky),
        'Шалгах',
        true,
        () => go(AppRoutes.savingsAccount),
      ),
      (
        'Гэрийн даалгавраа хийх',
        Mascots.bearBooks,
        10000,
        AppColors.emerald600,
        null,
        'Биелүүлэх',
        false,
        () => showAppSnack(context, 'Даалгавраа эцэг эхдээ батлуулаарай'),
      ),
      (
        'Санхүүгийн бяцхан хичээл үзэх',
        Mascots.owlBook,
        3000,
        AppColors.sky600,
        null,
        'Үзэх',
        false,
        () => showAppSnack(
          context,
          'Хичээл удахгүй нээгдэнэ',
          mascot: Mascots.owlBook,
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: kPageBackground,
      appBar: SubPageHeader(
        title: 'Урамшуулал авах',
        subtitle: 'Оноо цуглуулах боломжууд',
        trailing: CircleIconButton(
          icon: Icons.help_outline_rounded,
          label: 'Мэдээлэл',
          onPressed: () => showAppSnack(context, '1 оноо = 1₮'),
        ),
      ),
      body: EntranceScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            AppCard(
              radius: 24,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          'Даалгавар биелүүлж урамшуулал ав!',
                          size: 18,
                          weight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      const MascotImage(
                        asset: Mascots.redPandaTrophy,
                        size: 112,
                        background: Colors.white,
                        semanticLabel: 'Урамшуулал авсан бамбарууш',
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.slate100),
                  Row(
                    children: [
                      const Expanded(
                        child: _Stat(
                          icon: Icons.verified_rounded,
                          label: 'Нийт боломж',
                          value: '5 даалгавар',
                          tone: BadgeTone.sky,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Stat(
                          icon: Icons.monetization_on_rounded,
                          label: 'Боломжит дүн',
                          value: _dailyClaimed ? 33000 : 34000,
                          tone: BadgeTone.amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const SectionHeader(
              title: 'Урамшуулал авах аргууд',
              icon: Icons.military_tech_rounded,
              action: 'Шинэ боломжууд',
              padding: EdgeInsets.fromLTRB(4, 0, 4, 10),
            ),
            for (final (i, t) in tasks.indexed) ...[
              ListItemEntrance(
                id: t,
                index: i,
                child: _TaskTile(
                  title: t.$1,
                  asset: t.$2,
                  points: t.$3,
                  pointsColor: t.$4,
                  badge: t.$5,
                  action: t.$6,
                  primary: t.$7,
                  onTap: t.$8,
                ),
              ),
              const SizedBox(height: 10),
            ],
            _TaskTile(
              title: 'Өдөр бүр аппдаа нэвтрэх',
              asset: Mascots.penguinChecklist,
              points: 1000,
              pointsColor: AppColors.emerald600,
              action: _dailyClaimed ? 'Авсан ✓' : 'Авах',
              green: true,
              onTap: _dailyClaimed
                  ? null
                  : () {
                      setState(() => _dailyClaimed = true);
                      showAppSnack(
                        context,
                        '+₮1,000 оноо авлаа',
                        mascot: Mascots.bearConfetti,
                      );
                    },
            ),
            const SizedBox(height: 16),
            AppCard(
              radius: 18,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.sky50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.sky600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppText(
                        'Оноогоо хэрхэн зарцуулах вэ?',
                        size: 13,
                        weight: FontWeight.w700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    'Цуглуулсан оноогоороо халаасны мөнгө болгон хэтэвч рүүгээ шилжүүлэх эсвэл Roblox, Интерном, Кино тасалбар зэрэг бэлгийн эрхүүдээс сонгон авах боломжтой.',
                    size: 12,
                    color: AppColors.slate500,
                    height: 1.6,
                  ),
                  const SizedBox(height: 10),
                  const Wrap(
                    spacing: 8,
                    children: [
                      StatusBadge(
                        label: 'Хэтэвчинд бэлэн мөнгө',
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      StatusBadge(
                        label: 'Бэлгийн эрх',
                        icon: Icons.redeem_rounded,
                        tone: BadgeTone.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;

  /// An amount (shown signed with [BalanceText]) or preformatted text.
  final Object value;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = tone.colors;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: fg),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  size: 10,
                  weight: FontWeight.w600,
                  color: tone == BadgeTone.amber ? fg : AppColors.slate400,
                ),
                FittedBox(
                  child: switch (value) {
                    final num amount => BalanceText(
                      amount,
                      animate: true,
                      sign: true,
                      space: false,
                      size: 13,
                      weight: FontWeight.w800,
                      color: fg,
                    ),
                    _ => Text(
                      '$value',
                      style: moneyStyle(
                        size: 13,
                        weight: FontWeight.w800,
                        color: fg,
                      ),
                    ),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.title,
    required this.asset,
    required this.points,
    required this.pointsColor,
    required this.action,
    required this.onTap,
    this.badge,
    this.primary = false,
    this.green = false,
  });

  final String title;
  final String asset;
  final int points;
  final Color pointsColor;
  final (String, BadgeTone)? badge;
  final String action;
  final bool primary;
  final bool green;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 18,
      child: Row(
        children: [
          MascotImage(
            asset: asset,
            size: 48,
            background: Colors.white,
            semanticLabel: title,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppText(title, size: 13, weight: FontWeight.w700),
                    if (badge != null)
                      StatusBadge(label: badge!.$1, tone: badge!.$2),
                  ],
                ),
                const SizedBox(height: 2),
                // Shrinks rather than overflowing on a narrow tile.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BalanceText(
                        points,
                        sign: true,
                        space: false,
                        size: 12,
                        weight: FontWeight.w800,
                        color: pointsColor,
                      ),
                      Text(
                        ' оноо',
                        style: moneyStyle(
                          size: 12,
                          weight: FontWeight.w800,
                          color: pointsColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SoftButton(
            label: action,
            height: 32,
            background: primary
                ? AppColors.sky500
                : green
                ? AppColors.emerald50
                : AppColors.sky50,
            foreground: primary
                ? Colors.white
                : green
                ? AppColors.emerald600
                : AppColors.sky600,
            border: null,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
