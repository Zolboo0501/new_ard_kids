import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../app/kid_profile.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/units.dart';
import '../widgets/account_section_title.dart';
import '../widgets/account_unit_balance.dart';
import '../widgets/reward_offer_tile.dart';

/// "Урамшуулал": the offers that earn reward points.
class RewardOpportunitiesScreen extends StatefulWidget {
  const RewardOpportunitiesScreen({super.key});

  @override
  State<RewardOpportunitiesScreen> createState() =>
      _RewardOpportunitiesScreenState();
}

class _RewardOpportunitiesScreenState extends State<RewardOpportunitiesScreen> {
  static const _dailyPoints = 1000;

  bool _dailyClaimed = false;

  @override
  Widget build(BuildContext context) {
    void go(String r) => context.push(r);

    final offers = [
      (
        LineGlyph.personAdd,
        'Найз урих',
        Limits.inviteBonus,
        () => go(AppRoutes.inviteFriends),
      ),
      (
        LineGlyph.piggy,
        '3 сар дараалан хадгалах',
        15000,
        () => go(AppRoutes.savingsAccount),
      ),
      (
        LineGlyph.card,
        'Картаар анхны төлбөр хийх',
        10000,
        () => go(AppRoutes.card),
      ),
      (
        LineGlyph.graduation,
        'Санхүүгийн хичээл үзэх',
        3000,
        () => showAppSnack(context, 'Хичээл удахгүй нээгдэнэ'),
      ),
    ];
    final available =
        offers.fold<int>(0, (sum, o) => sum + o.$3) +
        (_dailyClaimed ? 0 : _dailyPoints);
    final count = offers.length + 1;
    final hairline = Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: AppColors.line,
    );

    return Scaffold(
      backgroundColor: kPageBackground,
      appBar: SubPageHeader(
        title: 'Урамшуулал',
        subtitle: 'Оноо цуглуулах саналууд',
        trailing: CircleIconButton(
          icon: Iconsax.message_question_copy,
          label: 'Мэдээлэл',
          onPressed: () => showAppSnack(context, '1 оноо = ₮1'),
        ),
      ),
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Авах боломжтой',
                    size: 13,
                    weight: FontWeight.w500,
                    color: AppColors.slate500,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AccountUnitBalance(
                      amount: available,
                      unit: pointUnit,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    '$count санал · ≈ ${formatMnt(available)}',
                    size: 13,
                    color: AppColors.slate500,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const AccountSectionTitle('Саналууд'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  for (final (i, o) in offers.indexed) ...[
                    if (i > 0) hairline,
                    ListItemEntrance(
                      id: o.$2,
                      index: i,
                      child: RewardOfferTile(
                        glyph: o.$1,
                        title: o.$2,
                        points: o.$3,
                        onTap: o.$4,
                      ),
                    ),
                  ],
                  hairline,
                  RewardOfferTile(
                    glyph: LineGlyph.calendar,
                    title: 'Өдөр бүр нэвтрэх',
                    points: _dailyPoints,
                    button: 'Авах',
                    done: _dailyClaimed,
                    onTap: () {
                      setState(() => _dailyClaimed = true);
                      showAppSnack(
                        context,
                        '${formatUnits(_dailyPoints, pointUnit, sign: true)} авлаа',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const InfoNote(
              title: 'Оноогоо хэрхэн зарцуулах вэ',
              text:
                  '1 оноо = ₮1. Оноогоо халаасны данс руугаа шилжүүлэх эсвэл Roblox, Интерном, кино тасалбарын эрхийн бичиг авах боломжтой.',
            ),
          ]),
        ),
      ),
    );
  }
}
