import 'package:flutter/material.dart';

import '../../../../app/avatar.dart';
import '../../../../widgets/avatar_card_art.dart';

import '../../../../app/accounts.dart';
import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/date_range_filter.dart';
import '../../../../widgets/date_range_sheet.dart';
import '../../../../widgets/ui.dart';
import '../../data/tx_item.dart';
import '../../data/units.dart';
import '../widgets/account_hero_panel.dart';
import '../widgets/account_section_title.dart';
import '../widgets/account_totals.dart';
import '../widgets/account_unit_balance.dart';
import '../widgets/copy_account_number.dart';
import '../widgets/transaction_list.dart';

/// "Койны данс": the Ард койн balance and its transactions. It is the
/// "Койн" tab of [RewardsAccountScreen], so it lays out as a [Column] inside
/// that screen's list rather than owning a scaffold.
class CoinAccountPane extends StatefulWidget {
  const CoinAccountPane({
    super.key,
    this.hidden = false,
    required this.onToggleHidden,
  });

  /// Whether the screen's eye button hides the number and balance.
  final bool hidden;
  final VoidCallback onToggleHidden;

  @override
  State<CoinAccountPane> createState() => _CoinAccountPaneState();
}

class _CoinAccountPaneState extends State<CoinAccountPane> {
  static List<TxItem> get _items => [
    TxItem(
      title: 'Өдрийн идэвх',
      subtitle: 'Апп ашигласан',
      date: daysAgo(0),
      amount: 5000,
      glyph: LineGlyph.checkCircle,
    ),
    TxItem(
      title: 'Roblox карт',
      subtitle: 'Тоглоом/Апп',
      date: daysAgo(13),
      amount: -15000,
      glyph: LineGlyph.gamepad,
    ),
    TxItem(
      title: 'Математикийн шалгалт',
      subtitle: 'Ааваас',
      date: daysAgo(15),
      amount: 20000,
      glyph: LineGlyph.graduation,
    ),
    TxItem(
      title: 'Найз урьсан',
      subtitle: 'Урилгын урамшуулал',
      date: daysAgo(18),
      amount: 10000,
      glyph: LineGlyph.personAdd,
    ),
    TxItem(
      title: 'Хадгаламжийн сорил',
      subtitle: 'Сар бүр хадгалсан',
      date: daysAgo(21),
      amount: 30000,
      glyph: LineGlyph.piggy,
    ),
    TxItem(
      title: 'Уншлагын сорил',
      subtitle: 'Сургууль',
      date: daysAgo(40),
      amount: 8000,
      glyph: LineGlyph.book,
    ),
    TxItem(
      title: 'Кино тасалбар',
      subtitle: 'Бусад',
      date: daysAgo(70),
      amount: -12000,
      glyph: LineGlyph.receipt,
    ),
  ];

  int _filter = 0;
  DateTimeRange _range = thisMonthRange();

  @override
  Widget build(BuildContext context) {
    // The date range narrows the list first; the chips then split it into
    // income and spending, and count within the range.
    final inRange = _items.where((e) => rangeContains(_range, e.date));
    final visible = switch (_filter) {
      1 => inRange.where((e) => e.income),
      2 => inRange.where((e) => !e.income),
      _ => inRange,
    }.toList();
    final income = _items
        .where((e) => e.income)
        .fold(0, (a, e) => a + e.amount);
    final spent = _items
        .where((e) => !e.income)
        .fold(0, (a, e) => a - e.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AvatarCardArt(
          sticker: Stickers.coin,
          size: 100,
          child: AccountHeroPanel(
            accent: AppColors.emerald500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CopyAccountNumber(
                  number: Accounts.coin,
                  hidden: widget.hidden,
                  onToggleHidden: widget.onToggleHidden,
                ),
                const SizedBox(height: 8),
                AppText(
                  'Нийт койны үлдэгдэл',
                  size: 13,
                  weight: FontWeight.w500,
                  color: AppColors.slate500,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Image.asset(
                      Mascots.ardCoin3d,
                      width: 36,
                      height: 36,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AccountUnitBalance(
                          amount: Balances.coins,
                          unit: coinUnit,
                          hidden: widget.hidden,
                          size: 36,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AppText(
                  widget.hidden
                      ? '1 койн = ₮1'
                      : '≈ ${formatMnt(Balances.coins)} · 1 койн = ₮1',
                  size: 13,
                  color: AppColors.slate500,
                ),
                Divider(height: 32, thickness: 1, color: AppColors.line),
                AccountTotals(
                  earned: income,
                  spent: spent,
                  unit: coinUnit,
                  hidden: widget.hidden,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final (i, l) in [
              'Бүгд (${inRange.length})',
              'Орлого (${inRange.where((e) => e.income).length})',
              'Зарлага (${inRange.where((e) => !e.income).length})',
            ].indexed)
              FilterChipPill(
                label: l,
                selected: _filter == i,
                onTap: () => setState(() => _filter = i),
              ),
          ],
        ),
        const SizedBox(height: 12),
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
            unit: coinUnit,
            group: (_filter, _range),
            // The pane fades in with its tab, so rows cascade every time it
            // appears, after the tab switch has started.
            always: true,
            delay: AppTabView.incomingDelay,
          ),
      ],
    );
  }
}
