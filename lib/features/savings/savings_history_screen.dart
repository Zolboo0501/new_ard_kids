import 'package:flutter/material.dart';

import '../../app/accounts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/date_range_filter.dart';
import '../../widgets/date_range_sheet.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';
import '../../widgets/entrance.dart';
import '../../app/avatar.dart';

/// "Хадгаламжийн данс - Гүйлгээний түүх": savings activity grouped by month.
class SavingsHistoryScreen extends StatefulWidget {
  const SavingsHistoryScreen({super.key});

  @override
  State<SavingsHistoryScreen> createState() => _SavingsHistoryScreenState();
}

class _SavingsHistoryScreenState extends State<SavingsHistoryScreen> {
  static final _now = DateTime.now();

  /// Mock entries dated relative to today, spread over five months, so
  /// widening the range from this month brings older ones in.
  /// (title, category, date, amount, sticker, tint)
  static List<(String, String, DateTime, int, String, Color)> get _entries {
    DateTime ago(int days) => dateOnly(_now.subtract(Duration(days: days)));
    return [
      (
        'Сар бүрийн хүү бодогдов',
        'Хүүхдийн өсөлтийн хүү',
        ago(13),
        14400,
        Stickers.growth,
        AppColors.amber50,
      ),
      (
        'Ааваас хадгаламжид нэмэв',
        'PlayStation 5 зорилго',
        ago(18),
        50000,
        Stickers.jar,
        AppColors.sky50,
      ),
      (
        'Зорилго биелэлтийн урамшуулал',
        'Ээжийн 50% урамшуулал',
        ago(21),
        25000,
        Stickers.gift,
        AppColors.rose50,
      ),
      (
        'Сар бүрийн хүү бодогдов',
        'Хүүхдийн өсөлтийн хүү',
        ago(44),
        13850,
        Stickers.growth,
        AppColors.amber50,
      ),
      (
        'Зуны амралтын шагнал',
        'Өвөө, эмээгээс дугуйн сан руу',
        ago(53),
        100000,
        Stickers.gift,
        AppColors.pink50,
      ),
      (
        'Сар бүрийн хүү бодогдов',
        'Хүүхдийн өсөлтийн хүү',
        ago(75),
        13200,
        Stickers.growth,
        AppColors.amber50,
      ),
      (
        'Ээжээс хадгаламжид нэмэв',
        'Дугуйн сан',
        ago(84),
        30000,
        Stickers.jar,
        AppColors.sky50,
      ),
      (
        'Сар бүрийн хүү бодогдов',
        'Хүүхдийн өсөлтийн хүү',
        ago(106),
        12600,
        Stickers.growth,
        AppColors.amber50,
      ),
      (
        'Төрсөн өдрийн бэлэг',
        'Авга эгчээс',
        ago(130),
        80000,
        Stickers.gift,
        AppColors.rose50,
      ),
    ];
  }

  /// Defaults to this month, up to today.
  DateTimeRange _range = thisMonthRange(now: _now);

  /// The entries inside [_range], grouped by month, newest first.
  List<(DateTime, List<(String, String, DateTime, int, String, Color)>)>
  get _months {
    final groups =
        <DateTime, List<(String, String, DateTime, int, String, Color)>>{};
    for (final e in _entries.where((e) => rangeContains(_range, e.$3))) {
      groups.putIfAbsent(DateTime(e.$3.year, e.$3.month), () => []).add(e);
    }
    return [
      for (final m in groups.keys.toList()..sort((a, b) => b.compareTo(a)))
        (m, groups[m]!..sort((a, b) => b.$3.compareTo(a.$3))),
    ];
  }

  String _monthLabel(DateTime m) {
    final offset = (_now.year - m.year) * 12 + _now.month - m.month;
    return switch (offset) {
      0 => 'ЭНЭ САР (${m.month}-Р САР)',
      1 => 'ӨНГӨРСӨН САР (${m.month}-Р САР)',
      _ when m.year != _now.year => '${m.year} ОНЫ ${m.month}-Р САР',
      _ => '${m.month}-Р САР',
    };
  }

  @override
  Widget build(BuildContext context) {
    final months = _months;
    return Scaffold(
      backgroundColor: AppColors.dsSurface,
      appBar: SubPageHeader(
        title: 'Хадгаламжийн түүх',
        background: AppColors.dsSurface,
        trailing: CircleIconButton(
          icon: Icons.tune_rounded,
          label: 'Хугацаагаар шүүх',
          onPressed: _pickRange,
        ),
      ),
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
              padding: const EdgeInsets.all(16),
              borderColor: AppColors.slate100,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BalanceText(
                              1280000,
                              size: 30,
                              weight: FontWeight.w600,
                              currencyWeight: FontWeight.w600,
                              currencyColor: AppColors.slate700,
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              'Хаан банк · ${formatIban(Accounts.khanBank)}',
                              size: 10,
                              weight: FontWeight.w600,
                              color: AppColors.slate400,
                            ),
                          ],
                        ),
                      ),
                      MascotImage(
                        asset: Stickers.report,
                        size: 90,
                        background: Colors.white,
                        semanticLabel: 'Гүйлгээний түүх харж буй маскот',
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.slate100),
                  Row(
                    children: [
                      _stat(
                        'Бодогдсон хүү',
                        48250,
                        AppColors.emerald600,
                        CrossAxisAlignment.start,
                      ),
                      _stat(
                        'Жилийн хүү',
                        '13.5%',
                        AppColors.sky600,
                        CrossAxisAlignment.center,
                      ),
                      _stat(
                        'Энэ сарын орлого',
                        150000,
                        AppColors.slate800,
                        CrossAxisAlignment.end,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DateRangeFilterBar(
              range: _range,
              count: months.fold(0, (a, m) => a + m.$2.length),
              onChanged: (r) => setState(() => _range = r),
            ),
            const SizedBox(height: 16),
            if (months.isEmpty) const DateRangeEmpty(),
            for (final (month, items) in months) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(
                        _monthLabel(month),
                        size: 11,
                        weight: FontWeight.w700,
                        color: AppColors.slate400,
                        letterSpacing: 0.8,
                      ),
                    ),
                    StatusBadge(
                      label: formatMnt(
                        items.fold(0, (a, e) => a + e.$4),
                        sign: true,
                      ),
                      tone: month.year == _now.year && month.month == _now.month
                          ? BadgeTone.emerald
                          : BadgeTone.slate,
                    ),
                  ],
                ),
              ),
              for (final (i, it) in items.indexed) ...[
                ListItemEntrance(
                  id: it,
                  index: i,
                  group: _range,
                  child: AppCard(
                    radius: 18,
                    padding: const EdgeInsets.all(12),
                    borderColor: AppColors.slate100,
                    child: Row(
                      children: [
                        MascotTile(
                          asset: it.$5,
                          size: 44,
                          background: it.$6,
                          label: it.$1,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(it.$1, size: 12, weight: FontWeight.w700),
                              const SizedBox(height: 2),
                              AppText(
                                '${it.$2} • ${it.$3.month} сарын '
                                '${it.$3.day.toString().padLeft(2, '0')}',
                                size: 10,
                                color: AppColors.slate400,
                              ),
                            ],
                          ),
                        ),
                        // Every entry is money coming in, so all amounts are green.
                        BalanceText(
                          it.$4,
                          sign: true,
                          size: 12,
                          color: AppColors.emerald600,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
            ],
          ]),
        ),
      ),
    );
  }

  /// [value] is either an amount (shown signed, with [BalanceText]) or
  /// preformatted text such as a percentage.
  Widget _stat(String label, Object value, Color color, CrossAxisAlignment a) {
    return Expanded(
      child: Column(
        crossAxisAlignment: a,
        children: [
          AppText(
            label,
            size: 9.5,
            weight: FontWeight.w500,
            color: AppColors.slate400,
          ),
          const SizedBox(height: 2),
          if (value is num)
            BalanceText(value, sign: true, size: 12, color: color)
          else
            Text('$value', style: moneyStyle(size: 12, color: color)),
        ],
      ),
    );
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangeSheet(context, initial: _range);
    if (picked != null) setState(() => _range = picked);
  }
}
