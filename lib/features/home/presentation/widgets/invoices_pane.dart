import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/invoice.dart';
import 'invoice_card.dart';

/// Home's Нэхэмжлэх tab: the newest invoices with status chips, then the
/// full statement and a new request.
class InvoicesPane extends StatelessWidget {
  const InvoicesPane({
    super.key,
    required this.filter,
    required this.onFilter,
    required this.onOpen,
  });

  final int filter;
  final ValueChanged<int> onFilter;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    // The newest few; the full, date-filtered list is the statement
    // (Хуулга харах).
    final recent = mockInvoices.take(3).toList();
    final visible = recent.where(invoiceFilters[filter].$2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final (i, (label, test)) in invoiceFilters.indexed)
              FilterChipPill(
                label: '$label (${recent.where(test).length})',
                selected: filter == i,
                onTap: () => onFilter(i),
              ),
          ],
        ),
        const SizedBox(height: 12),
        for (final (i, inv) in visible.indexed) ...[
          ListItemEntrance(
            always: true,
            delay: AppTabView.incomingDelay,
            id: inv.title,
            index: i,
            group: filter,
            child: InvoiceCard(invoice: inv),
          ),
          const SizedBox(height: 10),
        ],
        ListItemEntrance(
          id: #invoiceActions,
          index: visible.length,
          group: filter,
          always: true,
          delay: AppTabView.incomingDelay,
          child: Row(
            children: [
              Expanded(
                child: SoftButton(
                  label: 'Хуулга харах',
                  leading: LineIcon(
                    LineGlyph.receipt,
                    size: 18,
                    color: AppColors.slate900,
                  ),
                  background: AppColors.card,
                  foreground: AppColors.slate900,
                  border: AppColors.line,
                  onPressed: () => onOpen(AppRoutes.invoiceHistory),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SoftButton(
                  label: 'Хүсэлт үүсгэх',
                  leading: LineIcon(
                    LineGlyph.plus,
                    size: 18,
                    color: AppColors.slate900,
                  ),
                  background: AppColors.card,
                  foreground: AppColors.slate900,
                  border: AppColors.line,
                  onPressed: () => onOpen(AppRoutes.requestMoney),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
