import 'package:flutter/material.dart';

import '../../app/avatar.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text.dart';
import '../../widgets/common.dart';
import '../../widgets/date_range_filter.dart';
import '../../widgets/date_range_sheet.dart';
import '../../widgets/entrance.dart';
import '../../widgets/ui.dart';
import 'invoices.dart';

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
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            _SummaryCard(
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

/// Paid and still-open totals for the range, on Home's white card with the
/// companion's report sticker.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.paid,
    required this.paidCount,
    required this.open,
    required this.openCount,
  });

  final int paid;
  final int paidCount;
  final int open;
  final int openCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.sky100.withValues(alpha: 0.8)),
      ),
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
                      color: AppColors.slate400,
                    ),
                    const SizedBox(height: 2),
                    BalanceText(
                      paid,
                      animateFrom: 0,
                      size: 30,
                      weight: FontWeight.w600,
                      currencyWeight: FontWeight.w600,
                      currencyColor: AppColors.slate700,
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
                background: Colors.white,
                semanticLabel: 'Хуулга харж буй маскот',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.amber50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: AppColors.amber500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    openCount == 0
                        ? 'Хүлээгдэж буй нэхэмжлэх алга'
                        : '$openCount нэхэмжлэх хүлээгдэж байна',
                    size: 12,
                    weight: FontWeight.w600,
                    color: AppColors.slate700,
                  ),
                ),
                if (openCount > 0)
                  BalanceText(
                    open,
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.amber600,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
