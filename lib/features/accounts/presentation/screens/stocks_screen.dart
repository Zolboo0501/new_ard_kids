import 'package:flutter/material.dart';

import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/holding.dart';
import '../widgets/account_section_title.dart';
import '../widgets/stocks_holding_row.dart';

/// "Миний өв": the investment portfolio. Its total is [Balances.stocks],
/// the same number Home shows for this account.
class StocksScreen extends StatelessWidget {
  const StocksScreen({super.key});

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
            AppCard(
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
                  const SizedBox(height: 12),
                  AppText(
                    'Ногдол ашиг: компани ашгаасаа хувьцаа эзэмшигчдэд тараадаг мөнгө.',
                    size: 12,
                    color: AppColors.slate500,
                    height: 1.45,
                  ),
                ],
              ),
            ),
          ],
          trailing: [
            const AccountSectionTitle('Хувьцаанууд'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
