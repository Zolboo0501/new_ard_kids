import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/holding.dart';

/// One holding on "Миний өв": ticker tile, name over ticker and quantity,
/// value over the change since bought.
class StocksHoldingRow extends StatelessWidget {
  const StocksHoldingRow({super.key, required this.holding, this.onTap});

  final Holding holding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final h = holding;
    final up = h.change >= 0;
    return Semantics(
      button: onTap != null,
      child: Pressable(
        onTap: onTap,
        scale: 0.99,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AppText(
                        h.mark,
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.slate800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(h.name, size: 14, weight: FontWeight.w600),
                      const SizedBox(height: 2),
                      AppText(
                        '${h.ticker} · ${h.quantity}',
                        size: 12,
                        color: AppColors.slate500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    BalanceText(h.value, size: 14, weight: FontWeight.w600),
                    const SizedBox(height: 2),
                    Text(
                      '${up ? '+' : ''}${h.change}%',
                      style: moneyStyle(
                        size: 13,
                        weight: FontWeight.w500,
                        color: up ? AppColors.emerald600 : AppColors.rose600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
