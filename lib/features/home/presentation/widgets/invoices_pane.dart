import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import 'invoice_card.dart';
import '../../data/invoice.dart';
import 'dashed_action.dart';

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
          children: [
            for (final (i, (label, test)) in invoiceFilters.indexed)
              FilterChipPill(
                label: '$label (${recent.where(test).length})',
                selected: filter == i,
                onTap: () => onFilter(i),
              ),
          ],
        ),
        const SizedBox(height: 10),
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
          id: #invoiceHistory,
          index: visible.length,
          group: filter,
          always: true,
          delay: AppTabView.incomingDelay,
          child: SoftButton(
            label: 'Хуулга харах',
            icon: Icons.receipt_long_rounded,
            onPressed: () => onOpen(AppRoutes.invoiceHistory),
          ),
        ),
        const SizedBox(height: 10),
        ListItemEntrance(
          id: #newInvoice,
          index: visible.length + 1,
          group: filter,
          always: true,
          delay: AppTabView.incomingDelay,
          child: DashedAction(
            icon: Icons.add_circle_outline_rounded,
            label: 'Шинэ нэхэмжлэх / хүсэлт үүсгэх',
            onTap: () => onOpen(AppRoutes.requestMoney),
          ),
        ),
      ],
    );
  }
}
