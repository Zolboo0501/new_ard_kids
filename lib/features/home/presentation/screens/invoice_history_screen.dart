import 'package:flutter/material.dart';

import '../../../../widgets/adaptive.dart';
import '../../../../widgets/date_range_filter.dart';
import '../../../../widgets/date_range_sheet.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/invoice_card.dart';
import '../../data/invoice.dart';
import '../widgets/summary_card.dart';

/// "Нэхэмжлэхийн хуулга": every invoice, filtered by date and status. Opened
/// from Хуулга харах on Home's Нэхэмжлэх tab, and built from the same parts
/// (page tint, white card, status chips, [InvoiceCard]).
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
            SummaryCard(
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
                child: InvoiceCard(invoice: inv),
              ),
              const SizedBox(height: 10),
            ],
          ]),
        ),
      ),
    );
  }
}
