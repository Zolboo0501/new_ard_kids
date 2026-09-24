import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/ui.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.title,
    required this.asset,
    required this.points,
    required this.pointsColor,
    required this.action,
    required this.onTap,
    this.badge,
    this.primary = false,
    this.green = false,
  });

  final String title;
  final String asset;
  final int points;
  final Color pointsColor;
  final (String, BadgeTone)? badge;
  final String action;
  final bool primary;
  final bool green;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 18,
      child: Row(
        children: [
          MascotImage(
            asset: asset,
            size: 48,
            background: Colors.white,
            semanticLabel: title,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppText(title, size: 13, weight: FontWeight.w700),
                    if (badge != null)
                      StatusBadge(label: badge!.$1, tone: badge!.$2),
                  ],
                ),
                const SizedBox(height: 2),
                // Shrinks rather than overflowing on a narrow tile.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BalanceText(
                        points,
                        sign: true,
                        space: false,
                        size: 12,
                        weight: FontWeight.w800,
                        color: pointsColor,
                      ),
                      Text(
                        ' оноо',
                        style: moneyStyle(
                          size: 12,
                          weight: FontWeight.w800,
                          color: pointsColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SoftButton(
            label: action,
            height: 32,
            background: primary
                ? AppColors.sky500
                : green
                ? AppColors.emerald50
                : AppColors.sky50,
            foreground: primary
                ? Colors.white
                : green
                ? AppColors.emerald600
                : AppColors.sky600,
            border: Colors.transparent,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
