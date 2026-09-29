import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One label/value pair of the request list's summary row.
class RequestListSummary extends StatelessWidget {
  const RequestListSummary({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;

  /// An amount (a [num], shown with [BalanceText] and ₮) or a count, passed
  /// as a [String] so it gets no currency sign.
  final Object value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            size: 12,
            color: AppColors.slate500,
            maxLines: 2,
            height: 1.25,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: switch (value) {
              final num amount => BalanceText(
                amount,
                animate: true,
                size: 18,
                weight: FontWeight.w600,
                color: AppColors.slate900,
              ),
              _ => Text(
                '$value',
                style: moneyStyle(
                  size: 18,
                  weight: FontWeight.w600,
                  color: AppColors.slate900,
                ),
              ),
            },
          ),
        ],
      ),
    );
  }
}
