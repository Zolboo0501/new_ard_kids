import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// What the PIN confirms: the amount and who receives it.
class PinSummary extends StatelessWidget {
  const PinSummary({super.key, required this.amount, required this.recipient});

  final int amount;
  final String recipient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        children: [
          Text(
            formatMnt(amount),
            style: moneyStyle(size: 22, color: AppColors.slate900),
          ),
          const SizedBox(height: 2),
          AppText(
            '$recipient руу шилжүүлнэ',
            size: 12,
            weight: FontWeight.w600,
            color: AppColors.slate500,
          ),
        ],
      ),
    );
  }
}
