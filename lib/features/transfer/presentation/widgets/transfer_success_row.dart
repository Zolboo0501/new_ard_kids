import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';

class TransferSuccessRow extends StatelessWidget {
  const TransferSuccessRow({
    super.key,
    required this.label,
    required this.child,
    this.divider = false,
  });

  final String label;
  final Widget child;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: divider
          ? BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.line)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            size: 13,
            weight: FontWeight.w500,
            color: AppColors.slate500,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: child),
          ),
        ],
      ),
    );
  }
}
