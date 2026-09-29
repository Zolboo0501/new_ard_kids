import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';
import '../../../../widgets/value_switcher.dart';
import '../../data/units.dart';

/// A balance counted in coins or points rather than tugrik: the number
/// large, the [unit] after it smaller and grey (`50,000 койн`). The eye
/// button's [hidden] swaps it for dots, like [HideableBalance].
class AccountUnitBalance extends StatelessWidget {
  const AccountUnitBalance({
    super.key,
    required this.amount,
    required this.unit,
    this.hidden = false,
    this.size = 36,
    this.sign = false,
    this.weight = FontWeight.w600,
    this.color,
  });

  final num amount;
  final String unit;
  final bool hidden;
  final double size;
  final bool sign;
  final FontWeight weight;

  /// Defaults to `AppColors.slate900`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? AppColors.slate900;
    final unitStyle = inter(
      size: (size * 0.5).clamp(12, 20).toDouble(),
      weight: FontWeight.w500,
      color: this.color ?? AppColors.slate500,
    );
    return ValueSwitcher(
      value: hidden,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 240),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.centerLeft,
        children: [...previous, ?current],
      ),
      child: hidden
          ? Text(
              '••••••••',
              semanticsLabel: 'Үлдэгдэл нуусан',
              style: moneyStyle(size: size, color: color, letterSpacing: 4),
            )
          : Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: formatCount(amount, sign: sign),
                    style: moneyStyle(
                      size: size,
                      weight: weight,
                      color: color,
                      letterSpacing: size >= 28 ? -0.6 : null,
                    ),
                  ),
                  TextSpan(text: ' $unit', style: unitStyle),
                ],
              ),
              maxLines: 1,
            ),
    );
  }
}
