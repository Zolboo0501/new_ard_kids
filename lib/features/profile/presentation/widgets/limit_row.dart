import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class LimitRow extends StatelessWidget {
  const LimitRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final num value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: AppText(label, size: 11, color: AppColors.slate500)),
        BalanceText(value, size: 12, color: color),
      ],
    );
  }
}
