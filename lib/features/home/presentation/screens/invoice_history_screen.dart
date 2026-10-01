import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/date_range_filter.dart';
import '../../../../widgets/date_range_sheet.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/invoice_card.dart';
import '../../data/invoice.dart';

/// "Нэхэмжлэхийн хуулга": every invoice, filtered by date and status. Opened
/// from Хуулга харах on Home's Нэхэмжлэх tab, and built from the same parts
/// (status chips, [InvoiceCard]).
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
              runSpacing: 6,
              children: [
                for (final (i, (label, _)) in invoiceFilters.indexed)
                  FilterChipPill(
                    label: label,
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

  /// Paid and still-open totals for the range: the paid total large, then
  /// what is still waiting under a hairline.
  Widget _summary({
    required int paid,
    required int paidCount,
    required int open,
    required int openCount,
  }) {
    return AppCard(
      shadow: false,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Нийт төлөгдсөн',
            size: 13,
            weight: FontWeight.w500,
            color: AppColors.slate500,
          ),
          const SizedBox(height: 4),
          BalanceText(
            paid,
            animateFrom: 0,
            size: 32,
            weight: FontWeight.w700,
            color: AppColors.slate900,
            currencyColor: AppColors.slate900,
          ),
          const SizedBox(height: 2),
          AppText('$paidCount нэхэмжлэх', size: 12, color: AppColors.slate500),
          Divider(height: 28, color: AppColors.line),
          Row(
            children: [
              LineIcon(LineGlyph.clock, size: 18, color: AppColors.amber600),
              const SizedBox(width: 8),
              Expanded(
                child: AppText(
                  openCount == 0
                      ? 'Хүлээгдэж буй нэхэмжлэх алга'
                      : '$openCount нэхэмжлэх хүлээгдэж байна',
                  size: 13,
                  weight: FontWeight.w500,
                  color: AppColors.slate900,
                ),
              ),
              if (openCount > 0)
                BalanceText(
                  open,
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.slate900,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
