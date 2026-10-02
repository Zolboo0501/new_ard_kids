import 'package:flutter/material.dart';

import '../../../../app/avatar.dart';
import '../../../../widgets/avatar_card_art.dart';

import '../../../../app/accounts.dart';
import '../../../../app/kid_profile.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/date_range_filter.dart';
import '../../../../widgets/date_range_sheet.dart';
import '../../../../widgets/ui.dart';
import '../../data/tx_item.dart';
import '../../data/units.dart';
import 'account_hero_panel.dart';
import 'account_section_title.dart';
import 'account_totals.dart';
import 'account_unit_balance.dart';
import 'copy_account_number.dart';
import 'rewards_shortcut_row.dart';
import 'transaction_list.dart';

/// The "Урамшуулал" tab of [RewardsAccountScreen]: the points balance, the
/// ways to earn more, and the points history.
class RewardsPane extends StatefulWidget {
  const RewardsPane({
    super.key,
    required this.hidden,
    required this.onToggleHidden,
    required this.onOpen,
  });

  final bool hidden;
  final VoidCallback onToggleHidden;
  final ValueChanged<String> onOpen;

  @override
  State<RewardsPane> createState() => _RewardsPaneState();
}

class _RewardsPaneState extends State<RewardsPane> {
  static List<TxItem> get _items => [
    TxItem(
      title: 'Улирлын дүн',
      subtitle: 'Ааваас',
      date: daysAgo(0),
      amount: 10000,
      glyph: LineGlyph.graduation,
    ),
    TxItem(
      title: 'Хадгаламжийн зорилгод хүрсэн',
      subtitle: 'Ээжээс',
      date: daysAgo(1),
      amount: 15000,
      glyph: LineGlyph.target,
    ),
    TxItem(
      title: 'Найз урьсан',
      subtitle: 'Урилгын урамшуулал',
      date: daysAgo(11),
      amount: Limits.inviteBonus,
      glyph: LineGlyph.personAdd,
    ),
    TxItem(
      title: 'Картаар анхны төлбөр',
      subtitle: 'Урамшууллын санал',
      date: daysAgo(13),
      amount: 10000,
      glyph: LineGlyph.card,
    ),
    TxItem(
      title: 'Интерном эрхийн бичиг',
      subtitle: 'Оноо зарцуулсан',
      date: daysAgo(15),
      amount: -20000,
      glyph: LineGlyph.gift,
    ),
    TxItem(
      title: 'Сар дараалан хадгалсан',
      subtitle: 'Урамшууллын санал',
      date: daysAgo(45),
      amount: 8000,
      glyph: LineGlyph.piggy,
    ),
    TxItem(
      title: 'Тоглоомын дэлгүүр',
      subtitle: 'Оноо зарцуулсан',
      date: daysAgo(80),
      amount: -10000,
      glyph: LineGlyph.gamepad,
    ),
  ];

  DateTimeRange _range = thisMonthRange();

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final visible = items.where((e) => rangeContains(_range, e.date)).toList();
    // The card's totals cover the whole history; the date range only
    // narrows the list below.
    final earned = items
        .where((i) => i.income)
        .fold<int>(0, (sum, i) => sum + i.amount);
    final spent = items
        .where((i) => !i.income)
        .fold<int>(0, (sum, i) => sum - i.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Same structure as the coin card (number, balance, then the
        // totals) so switching tabs changes the content, not the layout;
        // the warm amber keeps the two accounts apart.
        AvatarCardArt(
          sticker: Stickers.gift,
          account: Accounts.rewards,
          area: 150,
          size: 100,
          child: AccountHeroPanel(
            accent: AppColors.amber500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CopyAccountNumber(
                  number: Accounts.rewards,
                  hidden: widget.hidden,
                  onToggleHidden: widget.onToggleHidden,
                ),
                const SizedBox(height: 8),
                AppText(
                  'Нийт үлдэгдэл',
                  size: 13,
                  weight: FontWeight.w500,
                  color: AvatarCardArt.mutedInk(context),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AccountUnitBalance(
                    amount: Balances.rewards,
                    unit: pointUnit,
                    hidden: widget.hidden,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 6),
                AppText(
                  widget.hidden
                      ? '1 оноо = ₮1'
                      : '≈ ${formatMnt(Balances.rewards)} · 1 оноо = ₮1',
                  size: 13,
                  color: AvatarCardArt.mutedInk(context),
                ),
                Divider(height: 32, thickness: 1, color: AppColors.line),
                AccountTotals(
                  earned: earned,
                  spent: spent,
                  unit: pointUnit,
                  hidden: widget.hidden,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Column(
            children: [
              RewardsShortcutRow(
                glyph: LineGlyph.personAdd,
                title: 'Найз урих',
                subtitle:
                    'Урилга бүрт ${formatUnits(Limits.inviteBonus, pointUnit)}',
                onTap: () => widget.onOpen(AppRoutes.inviteFriends),
              ),
              Divider(
                height: 1,
                thickness: 1,
                indent: 56,
                color: AppColors.line,
              ),
              RewardsShortcutRow(
                glyph: LineGlyph.gift,
                title: 'Урамшууллын саналууд',
                subtitle: 'Оноо цуглуулах боломжууд',
                onTap: () => widget.onOpen(AppRoutes.rewardOpportunities),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DateRangeFilterBar(
          range: _range,
          count: visible.length,
          onChanged: (r) => setState(() => _range = r),
        ),
        const SizedBox(height: 20),
        const AccountSectionTitle('Гүйлгээ'),
        if (visible.isEmpty)
          const DateRangeEmpty()
        else
          TransactionList(
            items: visible,
            unit: pointUnit,
            group: _range,
            always: true,
            delay: AppTabView.incomingDelay,
          ),
      ],
    );
  }
}
