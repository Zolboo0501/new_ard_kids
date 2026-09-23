import 'package:flutter/material.dart';

import '../../app/accounts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'account_widgets.dart';
import '../../widgets/app_tabs.dart';
import '../../widgets/app_text.dart';
import '../../widgets/date_range_filter.dart';
import '../../widgets/date_range_sheet.dart';
import '../../widgets/entrance.dart';
import '../../app/avatar.dart';

/// "Койны данс - Дэлгэрэнгүй": coin balance and transactions. It is the
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
      title: 'Өдөр тутмын чекин',
      subtitle: 'Хичээл & Апп идэвх',
      date: daysAgo(0),
      amount: 5000,
      asset: Mascots.penguinChecklist,
      tint: AppColors.amber50,
    ),
    TxItem(
      title: 'Roblox карт авах',
      subtitle: 'Тоглоом & Зугаа',
      date: daysAgo(13),
      amount: -15000,
      asset: Mascots.puppyGamepad,
      tint: AppColors.violet50,
      badge: 'Зарцуулсан',
      badgeTone: BadgeTone.rose,
    ),
    TxItem(
      title: 'Математикийн шалгалт амжилттай',
      subtitle: 'Ааваас урамшуулал',
      date: daysAgo(15),
      amount: 20000,
      asset: Mascots.owlMedal,
      tint: AppColors.sky50,
    ),
    TxItem(
      title: 'Найзаа урьж урамшуулал авав',
      subtitle: 'Найзын бэлэг',
      date: daysAgo(18),
      amount: 10000,
      asset: Stickers.gift,
      tint: AppColors.orange50,
      badge: 'Амжилттай',
    ),
    TxItem(
      title: 'Хадгаламжийн челленж',
      subtitle: 'Тэргүүн хэмнэгч',
      date: daysAgo(21),
      amount: 30000,
      asset: Mascots.hedgehogPiggy,
      tint: AppColors.amber50,
    ),
    TxItem(
      title: 'Долоо хоногийн уншлагын челленж',
      subtitle: 'Сургуулийн даалгавар',
      date: daysAgo(40),
      amount: 8000,
      asset: Mascots.owlBook,
      tint: AppColors.sky50,
    ),
    TxItem(
      title: 'Кино театрын тасалбар',
      subtitle: 'Тоглоом & Зугаа',
      date: daysAgo(70),
      amount: -12000,
      asset: Mascots.puppyGamepad,
      tint: AppColors.violet50,
      badge: 'Зарцуулсан',
      badgeTone: BadgeTone.rose,
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
        AppCard(
          radius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CopyAccountNumber(
                number: Accounts.coin,
                hidden: widget.hidden,
                onToggleHidden: widget.onToggleHidden,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Нийт койны үлдэгдэл',
                          size: 12,
                          weight: FontWeight.w500,
                          color: AppColors.slate400,
                        ),
                        const SizedBox(height: 2),
                        HideableBalance(
                          hidden: widget.hidden,
                          balance: const BalanceText(
                            50000,
                            animateFrom: 0,
                            size: 30,
                            currencyWeight: FontWeight.w600,
                            currencyColor: AppColors.slate700,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.emerald400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            AppText(
                              'Хөрвүүлэх ханш: 1 Койн = 1₮',
                              size: 11,
                              color: AppColors.slate500,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  MascotImage(
                    asset: Stickers.coin,
                    size: 104,
                    background: Colors.white,
                    semanticLabel: 'Зоос барьсан үнэг',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      asset: Stickers.receive,
                      label: 'Нийт орлого',
                      value: income,
                      color: AppColors.emerald700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStat(
                      asset: Stickers.transfer,
                      label: 'Нийт зарцуулалт',
                      value: -spent,
                      color: AppColors.rose600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 6,
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
        const SizedBox(height: 16),
        SectionHeader(
          title: 'ГҮЙЛГЭЭНИЙ ЖАГСААЛТ',
          mascot: Stickers.report,
          padding: EdgeInsets.fromLTRB(4, 0, 4, 10),
        ),
        if (visible.isEmpty) const DateRangeEmpty(),
        for (final (i, item) in visible.indexed) ...[
          ListItemEntrance(
            id: item,
            index: i,
            group: (_filter, _range),
            // The pane fades in with its tab, so rows cascade every time it
            // appears, after the tab switch has started.
            always: true,
            delay: AppTabView.incomingDelay,
            child: TransactionTile(item: item),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.asset,
    required this.label,
    required this.value,
    required this.color,
  });

  final String asset;
  final String label;

  /// Signed amount: shown as `+₮ …` or `-₮ …`.
  final num value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          MascotImage(
            asset: asset,
            size: 40,
            background: Colors.white,
            semanticLabel: label,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  size: 10,
                  weight: FontWeight.w500,
                  color: AppColors.slate400,
                ),
                FittedBox(
                  child: BalanceText(
                    value,
                    sign: true,
                    space: false,
                    size: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
