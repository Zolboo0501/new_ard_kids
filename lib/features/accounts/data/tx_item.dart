import 'package:flutter/material.dart';

import '../../../widgets/date_range_sheet.dart';
import '../../../widgets/ui.dart';

/// One row in an account's transaction list.
class TxItem {
  const TxItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    required this.glyph,
    this.tint,
    this.ink,
    this.badge,
    this.badgeTone = BadgeTone.emerald,
    this.amountColor,
  });

  final String title;
  final String subtitle;

  /// When it happened; lists filter on it with [rangeContains].
  final DateTime date;
  final int amount;

  /// The category glyph drawn in the row's tile.
  final LineGlyph glyph;

  /// The tile's fill and glyph colour; default `AppColors.slate50` and
  /// `AppColors.slate800`.
  final Color? tint;
  final Color? ink;

  /// A real status only (e.g. Хүлээгдэж буй), never a restatement of the sign.
  final String? badge;
  final BadgeTone badgeTone;
  final Color? amountColor;

  bool get income => amount >= 0;

  /// `Өнөөдөр`, `Өчигдөр`, else `09.10`; see [dayLabel].
  String get when => dayLabel(date);
}
