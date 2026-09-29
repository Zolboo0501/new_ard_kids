import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import 'invoice_card.dart';
import '../../data/invoice.dart';
import 'dashed_action.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';

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
              _NightChip(
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
            child: InvoiceCard(invoice: inv, dark: true),
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
            leading: LineIcon(
              LineGlyph.receipt,
              size: 18,
              color: AppColors.sky500,
            ),
            background: Night.surface,
            foreground: Night.text,
            border: Night.line,
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
            icon: LineGlyph.plusCircle,
            label: 'Шинэ нэхэмжлэх / хүсэлт үүсгэх',
            onTap: () => onOpen(AppRoutes.requestMoney),
          ),
        ),
      ],
    );
  }
}

/// A filter chip on the night surface: white when selected, outlined
/// otherwise.
class _NightChip extends StatelessWidget {
  const _NightChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: withHaptic(onTap),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? Colors.white : Night.line),
          ),
          child: AppText(
            label,
            size: 11.5,
            weight: FontWeight.w600,
            color: selected ? Night.bg : Night.text2,
          ),
        ),
      ),
    );
  }
}
