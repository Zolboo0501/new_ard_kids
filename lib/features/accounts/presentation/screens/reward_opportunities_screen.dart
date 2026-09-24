import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/avatar.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/reward_opportunities_stat.dart';
import '../widgets/task_tile.dart';

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
        Stickers.addFriend,
        5000,
        AppColors.amber600,
        ('Хялбар', BadgeTone.amber),
        'Урих',
        false,
        () => go(AppRoutes.inviteFriends),
      ),
      (
        'Хадгаламжийн зорилгодоо хүрэх',
        Stickers.goal,
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
                      MascotImage(
                        asset: Stickers.gift,
                        size: 112,
                        background: Colors.white,
                        semanticLabel: 'Бэлэг барьсан үнэг',
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.slate100),
                  Row(
                    children: [
                      const Expanded(
                        child: RewardOpportunitiesStat(
                          icon: Icons.verified_rounded,
                          label: 'Нийт боломж',
                          value: '5 даалгавар',
                          tone: BadgeTone.sky,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RewardOpportunitiesStat(
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
                child: TaskTile(
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
            TaskTile(
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
                        mascot: Stickers.success,
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
                        child: Icon(
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
