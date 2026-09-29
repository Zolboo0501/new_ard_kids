import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/tx_item.dart';
import 'transaction_tile.dart';

/// Transaction rows in one flat card, split by hairlines. Each row plays the
/// list cascade ([ListItemEntrance]) with the given [group], [always] and
/// [delay].
class TransactionList extends StatelessWidget {
  const TransactionList({
    super.key,
    required this.items,
    this.unit,
    this.group,
    this.always = false,
    this.delay = Duration.zero,
  });

  final List<TxItem> items;

  /// See [TransactionTile.unit].
  final String? unit;
  final Object? group;
  final bool always;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: [
          for (final (i, item) in items.indexed) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 56,
                color: AppColors.line,
              ),
            ListItemEntrance(
              id: item,
              index: i,
              group: group,
              always: always,
              delay: delay,
              child: TransactionTile(item: item, unit: unit),
            ),
          ],
        ],
      ),
    );
  }
}
