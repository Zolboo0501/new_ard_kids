import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class RelationButton extends StatelessWidget {
  const RelationButton({
    super.key,
    required this.label,
    required this.asset,
    required this.tint,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String asset;
  final Color tint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.sky50 : AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.card,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // The whole sticker, not cropped to a circle.
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(3),
                child: Image.asset(asset, fit: BoxFit.contain),
              ),
              const SizedBox(height: 4),
              AppText(
                label,
                size: 11,
                weight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? AppColors.sky700 : AppColors.slate600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
