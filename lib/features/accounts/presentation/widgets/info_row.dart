import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// A label and its value on one line, with a hairline under it unless
/// [last].
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.last = false,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          AppText(label, size: 13, color: AppColors.slate500),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: moneyStyle(
                size: 14,
                weight: FontWeight.w500,
                color: AppColors.slate900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
