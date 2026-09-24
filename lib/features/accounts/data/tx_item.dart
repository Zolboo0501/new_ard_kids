import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../widgets/date_range_sheet.dart';
import '../../../widgets/ui.dart';

/// One row in an account's transaction list.
class TxItem {
  const TxItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    required this.asset,
    this.tint,
    this.badge,
    this.badgeTone = BadgeTone.emerald,
    this.amountColor,
  });

  final String title;
  final String subtitle;

  /// When it happened; lists filter on it with [rangeContains].
  final DateTime date;
  final int amount;
  final String asset;

  /// Defaults to the theme accent (`AppColors.sky50`).
  final Color? tint;
  final String? badge;
  final BadgeTone badgeTone;
  final Color? amountColor;

  bool get income => amount >= 0;

  /// `Өнөөдөр`, `Өчигдөр`, else `09.10`; see [dayLabel].
  String get when => dayLabel(date);
}
