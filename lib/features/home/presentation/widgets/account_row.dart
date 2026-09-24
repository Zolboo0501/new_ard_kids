import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class AccountRow extends StatelessWidget {
  const AccountRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.mascot,
    this.amount,
    this.onTap,
    this.tileColor = Colors.white,
    this.trailing,
    this.locked = false,
  });

  final String title;
  final String subtitle;
  final String mascot;
  final int? amount;
  final VoidCallback? onTap;
  final Color tileColor;
  final Widget? trailing;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      radius: 18,
      color: locked ? AppColors.slate50 : Colors.white,
      borderColor: locked ? AppColors.slate200 : AppColors.sky100,
      dashed: locked,
      shadow: !locked,
      child: Opacity(
        opacity: locked ? 0.85 : 1,
        child: Row(
          children: [
            MascotTile(asset: mascot, background: tileColor, label: title),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    size: 13,
                    weight: FontWeight.w500,
                    color: locked ? AppColors.slate600 : AppColors.slate800,
                  ),
                  const SizedBox(height: 3),
                  AppText(
                    subtitle,
                    size: 11,
                    weight: FontWeight.w500,
                    color: AppColors.slate400,
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else ...[
              if (amount != null)
                BalanceText(
                  amount!,
                  size: 14,
                  weight: FontWeight.w600,
                  decimals: false,
                ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.slate400,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
