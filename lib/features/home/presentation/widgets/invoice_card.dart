import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/date_range_sheet.dart';
import '../../../../widgets/ui.dart';
import '../../data/invoice.dart';

/// An invoice row: mascot, title and status, the amount and day, and for an
/// open one a footer with its action (remind the parent, or pay).
class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key, required this.invoice, this.dark = false});

  final Invoice invoice;

  /// Draws the card on Home's night surface instead of white.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final inv = invoice;
    final text = dark ? Night.text : AppColors.slate800;
    final muted = dark ? Night.text2 : AppColors.slate400;
    return AppCard(
      radius: 18,
      color: dark ? Night.surface : Colors.white,
      borderColor: dark ? Night.surface : null,
      shadow: !dark,
      child: Column(
        children: [
          Row(
            children: [
              MascotTile(
                asset: inv.mascot,
                label: inv.title,
                background: dark ? Night.surface2 : Colors.white,
                radius: dark ? 24 : 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      inv.title,
                      size: 13,
                      weight: FontWeight.w500,
                      color: text,
                    ),
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
                                ? (dark ? Night.text2 : AppColors.slate500)
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
                    color: inv.open
                        ? text
                        : (dark ? AppColors.sky500 : AppColors.emerald600),
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    inv.open ? dayLabel(inv.date) : paidLabel(inv.date),
                    size: 11,
                    color: muted,
                  ),
                ],
              ),
            ],
          ),
          if (inv.open) ...[
            Divider(height: 20, color: dark ? Night.line : AppColors.slate100),
            Row(
              children: [
                Expanded(
                  child: AppText(inv.note ?? '', size: 11, color: muted),
                ),
                inv.status == InvoiceStatus.pending
                    ? SoftButton(
                        label: 'Сануулах',
                        leading: LineIcon(
                          LineGlyph.bellRing,
                          size: 16,
                          color: dark ? Night.text : AppColors.sky600,
                        ),
                        height: 30,
                        background: dark ? Night.surface2 : null,
                        foreground: dark ? Night.text : null,
                        border: dark ? Colors.transparent : null,
                        onPressed: () =>
                            showAppSnack(context, 'Ээжид сануулга илгээлээ'),
                      )
                    : SoftButton(
                        label: 'Төлөх',
                        leading: LineIcon(
                          LineGlyph.banknote,
                          size: 16,
                          color: dark ? AppColors.onAccent : Colors.white,
                        ),
                        height: 30,
                        background: dark ? AppColors.sky500 : AppColors.sky500,
                        foreground: dark ? AppColors.onAccent : Colors.white,
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
