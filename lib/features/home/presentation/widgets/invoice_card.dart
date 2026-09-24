import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/date_range_sheet.dart';
import '../../../../widgets/ui.dart';
import '../../data/invoice.dart';

/// An invoice row: mascot, title and status, the amount and day, and for an
/// open one a footer with its action (remind the parent, or pay).
class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key, required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final inv = invoice;
    return AppCard(
      radius: 18,
      child: Column(
        children: [
          Row(
            children: [
              MascotTile(asset: inv.mascot, label: inv.title),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(inv.title, size: 13, weight: FontWeight.w500),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: inv.statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: AppText(
                            inv.statusLabel,
                            size: 11,
                            weight: FontWeight.w600,
                            color: inv.status == InvoiceStatus.pending
                                ? AppColors.slate500
                                : inv.statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // A paid one is money settled: green, with when to the
                  // minute; an open one just says the day.
                  BalanceText(
                    inv.amount,
                    size: 14,
                    weight: FontWeight.w600,
                    color: inv.open ? AppColors.slate800 : AppColors.emerald600,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    inv.open ? dayLabel(inv.date) : paidLabel(inv.date),
                    size: 11,
                    color: AppColors.slate400,
                  ),
                ],
              ),
            ],
          ),
          if (inv.open) ...[
            const Divider(height: 20, color: AppColors.slate100),
            Row(
              children: [
                Expanded(
                  child: AppText(
                    inv.note ?? '',
                    size: 11,
                    color: AppColors.slate400,
                  ),
                ),
                inv.status == InvoiceStatus.pending
                    ? SoftButton(
                        label: 'Сануулах',
                        icon: Icons.notifications_active_outlined,
                        height: 30,
                        onPressed: () =>
                            showAppSnack(context, 'Ээжид сануулга илгээлээ'),
                      )
                    : SoftButton(
                        label: 'Төлөх',
                        icon: Icons.payments_outlined,
                        height: 30,
                        background: AppColors.sky500,
                        foreground: Colors.white,
                        border: Colors.transparent,
                        onPressed: () => {},
                      ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
