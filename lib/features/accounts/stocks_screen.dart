import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'account_widgets.dart';

/// "Хувьцаа & Хөрөнгө оруулалт": kid's investment portfolio.
class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  static const _holdings = [
    (
      'Apple',
      'AAPL',
      '0.2 хувьцаатай',
      145000,
      14.2,
      Icons.apple_rounded,
      AppColors.slate900,
      Colors.white,
    ),
    (
      'Disney',
      'DIS',
      '0.3 хувьцаатай',
      95000,
      8.5,
      Icons.castle_outlined,
      AppColors.sky50,
      AppColors.sky600,
    ),
    (
      'АПУ ХК',
      'МХБ: APU',
      '35 ширхэгтэй',
      68000,
      5.1,
      null,
      AppColors.amber50,
      AppColors.amber700,
    ),
    (
      'Roblox',
      'RBLX',
      '0.1 хувьцаатай',
      32000,
      -1.8,
      Icons.sports_esports_outlined,
      Color(0xFFFEF2F2),
      Color(0xFFEF4444),
    ),
  ];

  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final visible = _showAll ? _holdings : _holdings.take(4);
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: const SubPageHeader(
        title: 'Миний өв',
        subtitle: 'Хувьцаа & Хөрөнгө оруулалт',
        background: AppColors.slate50,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          AppCard(
            radius: 24,
            padding: const EdgeInsets.all(22),
            borderColor: AppColors.slate100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Хүүхдийн хөрөнгө оруулалтын данс',
                            style: comfortaa(
                              size: 12,
                              weight: FontWeight.w500,
                              color: AppColors.slate400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const CopyAccountNumber(
                            number: '•••• 9924',
                            prefix: 'Брокер: ',
                          ),
                        ],
                      ),
                    ),
                    const MascotImage(
                      asset: Mascots.otterInvest,
                      size: 80,
                      background: Colors.white,
                      semanticLabel: 'Mascot',
                    ),
                  ],
                ),
                Text(
                  'Нийт багцын үнэлгээ',
                  style: comfortaa(
                    size: 12,
                    weight: FontWeight.w500,
                    color: AppColors.slate400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatMnt(340000, space: true),
                  style: moneyStyle(
                    size: 30,
                    weight: FontWeight.w600,
                    color: AppColors.slate900,
                  ),
                ),
                const Divider(height: 28, color: AppColors.slate100),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      _stat('Оруулсан', '₮ 301,600', AppColors.slate700),
                      const VerticalDivider(
                        width: 1,
                        color: AppColors.slate100,
                      ),
                      _stat('Ашиг', '+₮ 38,400', AppColors.emerald600),
                      const VerticalDivider(
                        width: 1,
                        color: AppColors.slate100,
                      ),
                      _stat('Ногдол ашиг', '₮ 5,200', AppColors.amber600),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionHeader(
            title: 'Миний хувьцаанууд (${_holdings.length})',
            action: _showAll ? 'Хураах' : 'Бүгдийг харах',
            onAction: () => setState(() => _showAll = !_showAll),
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          ),
          for (final h in visible) ...[
            AppCard(
              radius: 18,
              padding: const EdgeInsets.all(14),
              borderColor: AppColors.slate100,
              onTap: () => showAppSnack(context, '${h.$1} (${h.$2})'),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: h.$7,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: h.$6 != null
                        ? Icon(h.$6, size: 22, color: h.$8)
                        : Text(
                            'АПУ',
                            style: comfortaa(
                              size: 11,
                              weight: FontWeight.w800,
                              color: h.$8,
                            ),
                          ),
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
                            Text(
                              h.$1,
                              style: comfortaa(
                                size: 14,
                                weight: FontWeight.w700,
                              ),
                            ),
                            StatusBadge(label: h.$2, tone: BadgeTone.slate),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          h.$3,
                          style: comfortaa(size: 12, color: AppColors.slate400),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatMnt(h.$4, space: true),
                        style: moneyStyle(size: 14),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            h.$5 >= 0
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 14,
                            color: h.$5 >= 0
                                ? AppColors.emerald600
                                : AppColors.rose500,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${h.$5 >= 0 ? '+' : ''}${h.$5}%',
                            style: comfortaa(
                              size: 12,
                              weight: FontWeight.w700,
                              color: h.$5 >= 0
                                  ? AppColors.emerald600
                                  : AppColors.rose500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          const InfoNote(
            icon: Icons.family_restroom_rounded,
            text:
                'Хувьцаа худалдан авах, зарах бүх гүйлгээ аав ээжийн зөвшөөрлөөр хийгдэнэ.',
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: comfortaa(size: 11, color: AppColors.slate400)),
          const SizedBox(height: 2),
          Text(value, style: moneyStyle(size: 12, color: color)),
        ],
      ),
    );
  }
}
