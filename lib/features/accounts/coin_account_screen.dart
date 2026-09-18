import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'account_widgets.dart';
import '../../widgets/app_text.dart';

/// "Койны данс - Дэлгэрэнгүй": coin balance and transactions.
class CoinAccountScreen extends StatefulWidget {
  const CoinAccountScreen({super.key});

  @override
  State<CoinAccountScreen> createState() => _CoinAccountScreenState();
}

class _CoinAccountScreenState extends State<CoinAccountScreen> {
  static const _items = [
    TxItem(
      title: 'Өдөр тутмын чекин',
      subtitle: 'Хичээл & Апп идэвх',
      when: 'Өнөөдөр',
      amount: 5000,
      asset: Mascots.penguinChecklist,
      tint: AppColors.amber50,
    ),
    TxItem(
      title: 'Roblox карт авах',
      subtitle: 'Тоглоом & Зугаа',
      when: '09.10',
      amount: -15000,
      asset: Mascots.puppyGamepad,
      tint: AppColors.violet50,
      badge: 'Зарцуулсан',
      badgeTone: BadgeTone.rose,
    ),
    TxItem(
      title: 'Математикийн шалгалт амжилттай',
      subtitle: 'Ааваас урамшуулал',
      when: '09.08',
      amount: 20000,
      asset: Mascots.owlMedal,
      tint: AppColors.sky50,
    ),
    TxItem(
      title: 'Найзаа урьж урамшуулал авав',
      subtitle: 'Найзын бэлэг',
      when: '09.05',
      amount: 10000,
      asset: Mascots.foxWave,
      tint: AppColors.orange50,
      badge: 'Амжилттай',
    ),
    TxItem(
      title: 'Хадгаламжийн челленж',
      subtitle: 'Тэргүүн хэмнэгч',
      when: '09.02',
      amount: 30000,
      asset: Mascots.hedgehogPiggy,
      tint: AppColors.amber50,
    ),
  ];

  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF5F9FF);
    final visible = switch (_filter) {
      1 => _items.where((e) => e.income),
      2 => _items.where((e) => !e.income),
      _ => _items,
    }.toList();
    final income = _items
        .where((e) => e.income)
        .fold(0, (a, e) => a + e.amount);
    final spent = _items
        .where((e) => !e.income)
        .fold(0, (a, e) => a - e.amount);

    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(
        title: 'Койны данс',
        background: bg,
        trailing: CircleIconButton(
          icon: Icons.calendar_month_outlined,
          label: 'Огноо шүүлтүүр',
          onPressed: () => showAppSnack(context, 'Огноо сонгох'),
        ),
      ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CopyAccountNumber(number: 'MN 5049 8219 04'),
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
                          FittedBox(
                            child: Text.rich(
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
                                    text: '50,000',
                                    style: moneyStyle(size: 34),
                                  ),
                                ],
                              ),
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
                    const MascotImage(
                      asset: Mascots.puppyPiggy,
                      size: 104,
                      background: Colors.white,
                      semanticLabel: 'PocketPal Puppy Saving Coins',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        asset: Mascots.bearHugCoin,
                        label: 'Нийт орлого',
                        value: '+${formatMnt(income, space: true)}',
                        color: AppColors.emerald700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniStat(
                        asset: Mascots.puppyGamepad,
                        label: 'Нийт зарцуулалт',
                        value: '-${formatMnt(spent, space: true)}',
                        color: AppColors.rose600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilterChipPill(
                label: 'Бүгд  ${_items.length}',
                selected: _filter == 0,
                onTap: () => setState(() => _filter = 0),
              ),
              const SizedBox(width: 8),
              FilterChipPill(
                label: '● Орлого',
                selected: _filter == 1,
                onTap: () => setState(() => _filter = 1),
              ),
              const SizedBox(width: 8),
              FilterChipPill(
                label: '● Зарлага',
                selected: _filter == 2,
                onTap: () => setState(() => _filter = 2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.sky100),
            ),
            child: Row(
              children: [
                AppText(
                  'Энэ сар (9-р сар)',
                  size: 12,
                  weight: FontWeight.w600,
                  color: AppColors.slate700,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AppText(
                    '| 2026.09.01 - 09.12',
                    size: 11,
                    color: AppColors.slate400,
                  ),
                ),
                AppText(
                  'Өөрчлөх',
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.sky600,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: '📑 ГҮЙЛГЭЭНИЙ ЖАГСААЛТ',
            padding: EdgeInsets.fromLTRB(4, 0, 4, 10),
          ),
          for (final item in visible) ...[
            TransactionTile(item: item),
            const SizedBox(height: 10),
          ],
        ],
      ),
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
  final String value;
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
                  child: Text(value, style: moneyStyle(size: 12, color: color)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
