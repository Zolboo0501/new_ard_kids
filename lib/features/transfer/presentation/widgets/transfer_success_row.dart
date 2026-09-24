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
      padding: EdgeInsets.only(top: divider ? 12 : 0, bottom: 12),
      decoration: divider
          ? const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.slate50)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            size: 13,
            weight: FontWeight.w500,
            color: AppColors.slate400,
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
