import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class SmallChip extends StatelessWidget {
  const SmallChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dot = false,
    this.asset,
    this.large = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dot;
  final String? asset;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: withHaptic(onTap),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: large ? 10 : 10,
            vertical: large ? 5 : 6,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.sky50 : AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.sky300 : AppColors.slate200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dot || (large && selected)) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.emerald500,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
              ],
              if (asset != null) ...[
                ClipOval(child: Image.asset(asset!, width: 24, height: 24)),
                const SizedBox(width: 6),
              ],
              AppText(
                label,
                size: 11,
                weight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? AppColors.sky700 : AppColors.slate600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
