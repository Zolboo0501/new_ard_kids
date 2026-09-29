import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import 'account_unit_balance.dart';

/// An account's earned and spent totals as two plain label/value pairs with
/// a hairline between them, in the account's [unit] (койн, оноо).
class AccountTotals extends StatelessWidget {
  const AccountTotals({
    super.key,
    required this.earned,
    required this.spent,
    required this.unit,
    this.hidden = false,
  });

  final int earned;

  /// Positive: what left the account.
  final int spent;
  final String unit;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _Total(
              label: 'Нийт орлого',
              child: AccountUnitBalance(
                amount: earned,
                unit: unit,
                sign: true,
                hidden: hidden,
                size: 16,
                color: AppColors.emerald600,
              ),
            ),
          ),
          VerticalDivider(width: 24, thickness: 1, color: AppColors.line),
          Expanded(
            child: _Total(
              label: 'Нийт зарцуулалт',
              child: AccountUnitBalance(
                amount: -spent,
                unit: unit,
                hidden: hidden,
                size: 16,
                color: AppColors.slate900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, size: 12, color: AppColors.slate500),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ],
    );
  }
}
