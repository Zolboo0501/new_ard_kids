import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';
import '../../widgets/entrance.dart';

/// "Хадгаламжийн данс - Гүйлгээний түүх": savings activity grouped by month.
class SavingsHistoryScreen extends StatefulWidget {
  const SavingsHistoryScreen({super.key});

  @override
  State<SavingsHistoryScreen> createState() => _SavingsHistoryScreenState();
}

class _SavingsHistoryScreenState extends State<SavingsHistoryScreen> {
  static const _months = [
    (
      'ЭНЭ САР (9-Р САР)',
      true,
      [
        (
          'Сар бүрийн хүү бодогдов',
          'Хүүхдийн өсөлтийн хүү • 9 сарын 10',
          14400,
          Mascots.owlAbacus,
          AppColors.amber50,
          AppColors.emerald600,
        ),
        (
          'Ааваас хадгаламжид нэмэв',
          'PlayStation 5 зорилго • 9 сарын 05',
          50000,
          Mascots.bearStar,
          AppColors.sky50,
          AppColors.sky600,
        ),
        (
          'Зорилго биелэлтийн урамшуулал',
          'Ээжийн 50% урамшуулал • 9 сарын 02',
          25000,
          Mascots.bearBooks,
          AppColors.rose50,
          AppColors.amber600,
        ),
      ],
    ),
    (
      'ӨНГӨРСӨН САР (8-Р САР)',
      false,
      [
        (
          'Сар бүрийн хүү бодогдов',
          'Хүүхдийн өсөлтийн хүү • 8 сарын 10',
          13850,
          Mascots.owlAbacus,
          AppColors.amber50,
          AppColors.emerald600,
        ),
        (
          'Зуны амралтын шагнал',
          'Өвөө, эмээгээс дугуйн сан руу • 8 сарын 01',
          100000,
          Mascots.bearStar,
          AppColors.pink50,
          AppColors.emerald600,
        ),
      ],
    ),
  ];

  int _range = 0;

  @override
  Widget build(BuildContext context) {
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
                              currencySize: 24,
                              weight: FontWeight.w600,
                              currencyWeight: FontWeight.w600,
                              currencyColor: AppColors.slate700,
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              'Данс: •••• 3384 | Хаан банк',
                              size: 10,
                              weight: FontWeight.w600,
                              color: AppColors.slate400,
                            ),
                          ],
                        ),
                      ),
                      const MascotImage(
                        asset: Mascots.sleepingCat,
                        size: 90,
                        background: Colors.white,
                        semanticLabel: 'Хөөрхөн унтаж буй муужгай',
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
            for (final (label, current, items) in _months) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(
                        label,
                        size: 11,
                        weight: FontWeight.w700,
                        color: AppColors.slate400,
                        letterSpacing: 0.8,
                      ),
                    ),
                    StatusBadge(
                      label: formatMnt(
                        items.fold(0, (a, e) => a + e.$3),
                        sign: true,
                      ),
                      tone: current ? BadgeTone.emerald : BadgeTone.slate,
                    ),
                  ],
                ),
              ),
              for (final (i, it) in items.indexed) ...[
                ListItemEntrance(
                  id: it,
                  index: i,
                  child: AppCard(
                    radius: 18,
                    padding: const EdgeInsets.all(12),
                    borderColor: AppColors.slate100,
                    child: Row(
                      children: [
                        MascotTile(
                          asset: it.$4,
                          size: 44,
                          background: it.$5,
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
                                it.$2,
                                size: 10,
                                color: AppColors.slate400,
                              ),
                            ],
                          ),
                        ),
                        BalanceText(it.$3, sign: true, size: 12, color: it.$6),
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
    const ranges = ['Сүүлийн 2 сар', 'Сүүлийн 6 сар', 'Энэ жил'];
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                'Хугацаагаар шүүх',
                size: 16,
                weight: FontWeight.w700,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              for (final (i, r) in ranges.indexed)
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: AppText(r, size: 14, weight: FontWeight.w600),
                  trailing: i == _range
                      ? const Icon(Icons.check_rounded, color: AppColors.sky500)
                      : null,
                  onTap: () => Navigator.of(context).pop(i),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _range = picked);
  }
}
