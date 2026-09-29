import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/date_range_sheet.dart';
import '../../../../widgets/ui.dart';
import '../../data/invoice.dart';

/// An invoice row: the category glyph, title and day, the amount, and for
/// an open invoice its status and a footer with the next step (remind the
/// parent, or pay).
class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key, required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final inv = invoice;
    return AppCard(
      color: AppColors.card,
      borderColor: AppColors.card,
      shadow: false,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: LineIcon(
                    inv.glyph,
                    size: 21,
                    color: AppColors.slate800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      inv.title,
                      size: 14,
                      weight: FontWeight.w600,
                      color: AppColors.slate900,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      inv.open ? dayLabel(inv.date) : paidLabel(inv.date),
                      size: 12,
                      color: AppColors.slate500,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BalanceText(
                    inv.amount,
                    size: 15,
                    weight: FontWeight.w600,
                    color: AppColors.slate900,
                  ),
                  if (inv.open) ...[
                    const SizedBox(height: 4),
                    StatusBadge(label: inv.statusLabel, tone: inv.statusTone),
                  ],
                ],
              ),
            ],
          ),
          if (inv.open) ...[
            Divider(height: 24, color: AppColors.line),
            Row(
              children: [
                Expanded(
                  child: AppText(
                    inv.note ?? '',
                    size: 12,
                    color: AppColors.slate500,
                  ),
                ),
                const SizedBox(width: 10),
                inv.status == InvoiceStatus.pending
                    ? SoftButton(
                        label: 'Сануулах',
                        leading: LineIcon(
                          LineGlyph.bellRing,
                          size: 16,
                          color: AppColors.slate900,
                        ),
                        height: 44,
                        background: AppColors.slate50,
                        foreground: AppColors.slate900,
                        border: Colors.transparent,
                        onPressed: () =>
                            showAppSnack(context, 'Ээжид сануулга илгээлээ'),
                      )
                    : SoftButton(
                        label: 'Төлөх',
                        leading: LineIcon(
                          LineGlyph.banknote,
                          size: 16,
                          color: AppColors.onAccent,
                        ),
                        height: 44,
                        background: AppColors.sky500,
                        foreground: AppColors.onAccent,
                        border: Colors.transparent,
                        onPressed: () {},
                      ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
