import 'package:flutter/material.dart';

import '../../../../app/accounts.dart';
import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/date_range_filter.dart';
import '../../../../widgets/date_range_sheet.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/savings_glyph_tile.dart';
import '../widgets/stat_strip.dart';

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
  /// (title, category, date, amount, glyph)
  static List<(String, String, DateTime, int, LineGlyph)> get _entries {
    DateTime ago(int days) => dateOnly(_now.subtract(Duration(days: days)));
    return [
      (
        'Сар бүрийн хүү бодогдов',
        'Сарын хүү',
        ago(13),
        14400,
        LineGlyph.percent,
      ),
      (
        'Ааваас хадгаламжид нэмэв',
        'PlayStation 5 Pro зорилго',
        ago(18),
        50000,
        LineGlyph.arrowDownLeft,
      ),
      (
        'Зорилго биелэлтийн урамшуулал',
        'Ээжийн 50% урамшуулал',
        ago(21),
        25000,
        LineGlyph.arrowDownLeft,
      ),
      (
        'Сар бүрийн хүү бодогдов',
        'Сарын хүү',
        ago(44),
        13850,
        LineGlyph.percent,
      ),
      (
        'Зуны амралтын шагнал',
        'Өвөө, эмээгээс дугуйн сан руу',
        ago(53),
        100000,
        LineGlyph.arrowDownLeft,
      ),
      (
        'Сар бүрийн хүү бодогдов',
        'Сарын хүү',
        ago(75),
        13200,
        LineGlyph.percent,
      ),
      (
        'Ээжээс хадгаламжид нэмэв',
        'Дугуйн сан',
        ago(84),
        30000,
        LineGlyph.arrowDownLeft,
      ),
      (
        'Сар бүрийн хүү бодогдов',
        'Сарын хүү',
        ago(106),
        12600,
        LineGlyph.percent,
      ),
      (
        'Төрсөн өдрийн бэлэг',
        'Авга эгчээс',
        ago(130),
        80000,
        LineGlyph.arrowDownLeft,
      ),
    ];
  }

  /// Defaults to this month, up to today.
  DateTimeRange _range = thisMonthRange(now: _now);

  /// The entries inside [_range], grouped by month, newest first.
  List<(DateTime, List<(String, String, DateTime, int, LineGlyph)>)>
  get _months {
    final groups =
        <DateTime, List<(String, String, DateTime, int, LineGlyph)>>{};
    for (final e in _entries.where((e) => rangeContains(_range, e.$3))) {
      groups.putIfAbsent(DateTime(e.$3.year, e.$3.month), () => []).add(e);
    }
    return [
      for (final m in groups.keys.toList()..sort((a, b) => b.compareTo(a)))
        (m, groups[m]!..sort((a, b) => b.$3.compareTo(a.$3))),
    ];
  }

  String _monthLabel(DateTime m) => m.year == _now.year
      ? '${m.month}-р сар'
      : '${m.year} оны ${m.month}-р сар';

  @override
  Widget build(BuildContext context) {
    final months = _months;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SubPageHeader(
        title: 'Хадгаламжийн түүх',
        background: AppColors.surface,
        trailing: CircleIconButton(
          icon: Icons.tune_rounded,
          label: 'Хугацаагаар шүүх',
          onPressed: _pickRange,
        ),
      ),
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
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
                      size: 36,
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
                      ('Энэ сарын орлого', 150000, AppColors.slate900),
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
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(
                        _monthLabel(month),
                        size: 13,
                        weight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                    Text(
                      formatMnt(items.fold(0, (a, e) => a + e.$4), sign: true),
                      style: moneyStyle(
                        size: 13,
                        weight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (final (i, it) in items.indexed) ...[
                      if (i > 0) Divider(height: 1, color: AppColors.line),
                      ListItemEntrance(
                        id: it,
                        index: i,
                        group: _range,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              SavingsGlyphTile(
                                glyph: it.$5,
                                tone: BadgeTone.emerald,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      it.$1,
                                      size: 14,
                                      weight: FontWeight.w600,
                                      color: AppColors.slate900,
                                    ),
                                    const SizedBox(height: 2),
                                    AppText(
                                      '${it.$2} · ${it.$3.month} сарын '
                                      '${it.$3.day.toString().padLeft(2, '0')}',
                                      size: 13,
                                      color: AppColors.slate500,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Every entry is money coming in.
                              BalanceText(
                                it.$4,
                                sign: true,
                                size: 14,
                                weight: FontWeight.w600,
                                color: AppColors.emerald600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ]),
        ),
      ),
    );
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangeSheet(context, initial: _range);
    if (picked != null) setState(() => _range = picked);
  }
}
