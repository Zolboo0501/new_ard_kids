import 'package:flutter/material.dart';

import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class ResultBox extends StatelessWidget {
  const ResultBox({
    super.key,
    required this.label,
    required this.value,
    this.sign = false,
    required this.background,
    required this.border,
    required this.labelColor,
    required this.valueColor,
  });

  final String label;
  final num value;
  final bool sign;
  final Color background;
  final Color border;
  final Color labelColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label, size: 10, weight: FontWeight.w600, color: labelColor),
          const SizedBox(height: 2),
          FittedBox(
            child: BalanceText(
              value,
              animate: true,
              sign: sign,
              size: 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
