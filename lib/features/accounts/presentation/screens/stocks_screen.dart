import 'package:flutter/material.dart';

import '../../../../app/accounts.dart';
import '../../../../widgets/avatar_card_art.dart';

import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/holding.dart';
import '../widgets/account_section_title.dart';
import '../widgets/stocks_holding_row.dart';
import '../../../../widgets/avatar_tour.dart';
import '../../../../app/avatar.dart';

/// "Миний өв": the investment portfolio. Its total is [Balances.stocks],
/// the same number Home shows for this account.
class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> with AvatarTourHost {
  /// What the first-visit tour points at.
  final _summaryKey = GlobalKey();
  final _holdingsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // The first visit: the avatar walks the teen through this screen.
    startAvatarTour('stocks', () {
      final name = appAvatar.value.name;
      return [
        AvatarTourStep(
          text: 'Би $name. Миний өв — хөрөнгө оруулалтаа энд харна!',
        ),
        AvatarTourStep(
          target: _summaryKey,
          text: 'Нийт багцын үнэлгээ, хэр өссөн нь энд.',
        ),
        AvatarTourStep(
          target: _holdingsKey,
          text: 'Эзэмшиж буй хувьцаанууд чинь энд жагсана.',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(
      mockHoldings.fold<int>(0, (a, h) => a + h.value) == Balances.stocks,
      'Holdings must add up to the total Home shows',
    );
    return Scaffold(
      backgroundColor: kPageBackground,
      appBar: const SubPageHeader(title: 'Миний өв'),
      body: EntranceScope(
        // Split on wide windows: the portfolio total beside the holdings.
        child: AdaptiveSplit(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          gap: 20,
          leading: [
            KeyedSubtree(
              key: _summaryKey,
              child: AvatarCardArt(
                account: Accounts.stocks,
                area: 118,
                child: AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Нийт багцын үнэлгээ',
                        size: 13,
                        weight: FontWeight.w500,
                        color: AppColors.slate500,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: BalanceText(
                          Balances.stocks,
                          animateFrom: 0,
                          size: 36,
                          weight: FontWeight.w600,
                          letterSpacing: -0.6,
                          currencyColor: AppColors.slate700,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        '+${(portfolioGain / portfolioInvested * 100).toStringAsFixed(1)}% нийт өгөөж',
                        size: 13,
                        weight: FontWeight.w500,
                        color: AppColors.emerald600,
                      ),
                      Divider(height: 32, thickness: 1, color: AppColors.line),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            _stat('Оруулсан', portfolioInvested),
                            VerticalDivider(
                              width: 24,
                              thickness: 1,
                              color: AppColors.line,
                            ),
                            _stat(
                              'Ашиг',
                              portfolioGain,
                              color: AppColors.emerald600,
                              sign: true,
                            ),
                            VerticalDivider(
                              width: 24,
                              thickness: 1,
                              color: AppColors.line,
                            ),
                            _stat('Ногдол ашиг', portfolioDividends),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          trailing: [
            const AccountSectionTitle('Хувьцаанууд'),
            KeyedSubtree(
              key: _holdingsKey,
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                child: Column(
                  children: [
                    for (final (i, h) in mockHoldings.indexed) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: 56,
                          color: AppColors.line,
                        ),
                      ListItemEntrance(
                        id: h.ticker,
                        index: i,
                        child: StocksHoldingRow(
                          holding: h,
                          onTap: () =>
                              showAppSnack(context, '${h.name} (${h.ticker})'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, num value, {Color? color, bool sign = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label, size: 12, color: AppColors.slate500),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: BalanceText(
              value,
              sign: sign,
              size: 15,
              weight: FontWeight.w600,
              color: color ?? AppColors.slate900,
            ),
          ),
        ],
      ),
    );
  }
}
