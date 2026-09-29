import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// A spending limit as a plain label/amount pair.
class LimitRow extends StatelessWidget {
  const LimitRow({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final num value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: AppText(label, size: 13, color: AppColors.slate500)),
        BalanceText(
          value,
          size: 14,
          weight: FontWeight.w600,
          color: color ?? AppColors.slate900,
        ),
      ],
    );
  }
}
