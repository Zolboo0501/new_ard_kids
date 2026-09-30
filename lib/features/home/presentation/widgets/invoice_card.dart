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
  const InvoiceCard({
    super.key,
    required this.invoice,
    this.background,
    this.showIcon = true,
  });

  final Invoice invoice;

  /// The category glyph tile before the title (Home's Нэхэмжлэх tab leaves
  /// it out).
  final bool showIcon;

  /// Framed art drawn behind the card (`invoiceCardArt`) and its
  /// width-to-height ratio.
  final ({String asset, double aspect})? background;

  @override
  Widget build(BuildContext context) {
    final art = background;
    final content = _content(context, framed: art != null);
    if (art == null) {
      return AppCard(
        color: AppColors.card,
        borderColor: AppColors.card,
        shadow: false,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: content,
      );
    }
    // The card takes the art's own shape, so the art is drawn at its own
    // proportions, never stretched; the content sits centred in it. Content
    // taller than that (large system text) grows the card and the art covers
    // it, cropping a little rather than stretching.
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        constraints: BoxConstraints(
          minHeight: constraints.maxWidth / art.aspect,
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(art.asset),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: content,
      ),
    );
  }

  /// [framed] tightens the gap around the divider so a two-line invoice
  /// still fits the art's shape.
  Widget _content(BuildContext context, {required bool framed}) {
    final inv = invoice;
    return Column(
      children: [
        Row(
          children: [
            if (showIcon) ...[
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
            ],
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
          Divider(height: framed ? 14 : 24, color: AppColors.line),
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
    );
  }
}
