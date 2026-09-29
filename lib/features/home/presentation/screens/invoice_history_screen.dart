import 'package:flutter/material.dart';

import '../../../../app/avatar.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/date_range_filter.dart';
import '../../../../widgets/date_range_sheet.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/invoice_card.dart';
import '../../data/invoice.dart';

/// "Нэхэмжлэхийн хуулга": every invoice, filtered by date and status. Opened
/// from Хуулга харах on Home's Нэхэмжлэх tab, and built from the same parts
/// (night canvas, status chips, [InvoiceCard] on the night surface).
class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  DateTimeRange _range = thisMonthRange();
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    // The date range narrows the list first; the chips and the totals then
    // work within it.
    final inRange = mockInvoices
        .where((e) => rangeContains(_range, e.date))
        .toList();
    final visible = inRange.where(invoiceFilters[_filter].$2).toList();
    final paid = inRange.where((e) => !e.open);
    final open = inRange.where((e) => e.open);

    return Scaffold(
      backgroundColor: kPageBackground,
      appBar: const SubPageHeader(title: 'Нэхэмжлэхийн хуулга'),
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            _summary(
              paid: paid.fold(0, (a, e) => a + e.amount),
              paidCount: paid.length,
              open: open.fold(0, (a, e) => a + e.amount),
              openCount: open.length,
            ),
            const SizedBox(height: 16),
            DateRangeFilterBar(
              range: _range,
              count: visible.length,
              onChanged: (r) => setState(() => _range = r),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: [
                for (final (i, (label, test)) in invoiceFilters.indexed)
                  FilterChipPill(
                    label: '$label (${inRange.where(test).length})',
                    selected: _filter == i,
                    onTap: () => setState(() => _filter = i),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (visible.isEmpty) const DateRangeEmpty(),
            for (final (i, inv) in visible.indexed) ...[
              ListItemEntrance(
                id: inv.title,
                index: i,
                group: (_filter, _range),
                child: InvoiceCard(invoice: inv, dark: true),
              ),
              const SizedBox(height: 10),
            ],
          ]),
        ),
      ),
    );
  }

  /// Paid and still-open totals for the range: a night hero panel with a
  /// faint accent wash from its top-left corner, as on Home's account panel.
  Widget _summary({
    required int paid,
    required int paidCount,
    required int open,
    required int openCount,
  }) {
    final accent = AppColors.sky500;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-1, -1),
            radius: 1.2,
            colors: [
              accent.withValues(alpha: 0.16),
              accent.withValues(alpha: 0),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Нийт төлөгдсөн',
                          size: 12,
                          weight: FontWeight.w500,
                          color: Night.text2,
                        ),
                        const SizedBox(height: 2),
                        BalanceText(
                          paid,
                          animateFrom: 0,
                          size: 30,
                          weight: FontWeight.w600,
                          color: Night.text,
                          currencyWeight: FontWeight.w600,
                          currencyColor: Night.text2,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          '$paidCount нэхэмжлэх төлөгдсөн',
                          size: 11,
                          weight: FontWeight.w600,
                          color: AppColors.emerald600,
                        ),
                      ],
                    ),
                  ),
                  MascotImage(
                    asset: Stickers.report,
                    size: 90,
                    background: AppColors.card,
                    semanticLabel: 'Хуулга харж буй маскот',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Night.surface2,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 18,
                      color: Night.amber,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        openCount == 0
                            ? 'Хүлээгдэж буй нэхэмжлэх алга'
                            : '$openCount нэхэмжлэх хүлээгдэж байна',
                        size: 12,
                        weight: FontWeight.w600,
                        color: Night.text,
                      ),
                    ),
                    if (openCount > 0)
                      BalanceText(
                        open,
                        size: 13,
                        weight: FontWeight.w700,
                        color: Night.amber,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
