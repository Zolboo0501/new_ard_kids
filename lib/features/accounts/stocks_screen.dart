import 'package:flutter/material.dart';

import '../../app/accounts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'account_widgets.dart';
import '../../widgets/app_text.dart';
import '../../widgets/entrance.dart';
import '../../app/avatar.dart';

/// "Хувьцаа & Хөрөнгө оруулалт": kid's investment portfolio.
class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  /// The eye button's state: hides the account number and portfolio value.
  bool _hidden = false;

  static List<(String, String, String, int, double, IconData?, Color, Color)>
  get _holdings => [
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
        background: AppColors.slate50,
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
                            AppText(
                              'Нийт багцын үнэлгээ',
                              size: 12,
                              weight: FontWeight.w500,
                              color: AppColors.slate400,
                            ),
                            const SizedBox(height: 2),
                            HideableBalance(
                              hidden: _hidden,
                              balance: const BalanceText(
                                340000,
                                animateFrom: 0,
                                space: false,
                                size: 30,
                                weight: FontWeight.w600,
                                color: AppColors.slate900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      MascotImage(
                        asset: Stickers.growth,
                        size: 80,
                        background: Colors.white,
                        semanticLabel: 'Өсөлтийн графиктай үнэг',
                      ),
                    ],
                  ),

                  const Divider(height: 28, color: AppColors.slate100),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        _stat('Оруулсан', 301600, AppColors.slate700),
                        const VerticalDivider(
                          width: 1,
                          color: AppColors.slate100,
                        ),
                        _stat('Ашиг', 38400, AppColors.emerald600, sign: true),
                        const VerticalDivider(
                          width: 1,
                          color: AppColors.slate100,
                        ),
                        _stat('Ногдол ашиг', 5200, AppColors.amber600),
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
            for (final (i, h) in visible.indexed) ...[
              ListItemEntrance(
                id: h,
                index: i,
                child: AppCard(
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
                            : AppText(
                                'АПУ',
                                size: 11,
                                weight: FontWeight.w800,
                                color: h.$8,
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
                                AppText(
                                  h.$1,
                                  size: 14,
                                  weight: FontWeight.w700,
                                ),
                                StatusBadge(label: h.$2, tone: BadgeTone.slate),
                              ],
                            ),
                            const SizedBox(height: 2),
                            AppText(h.$3, size: 12, color: AppColors.slate400),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          BalanceText(h.$4, space: false, size: 14),
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
                              AppText(
                                '${h.$5 >= 0 ? '+' : ''}${h.$5}%',
                                size: 12,
                                weight: FontWeight.w700,
                                color: h.$5 >= 0
                                    ? AppColors.emerald600
                                    : AppColors.rose500,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 6),
          ]),
        ),
      ),
    );
  }

  Widget _stat(String label, num value, Color color, {bool sign = false}) {
    return Expanded(
      child: Column(
        children: [
          AppText(label, size: 11, color: AppColors.slate400),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: BalanceText(
              value,
              sign: sign,
              space: false,
              size: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
