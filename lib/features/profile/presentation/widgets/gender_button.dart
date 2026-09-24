import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class GenderButton extends StatelessWidget {
  const GenderButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: withHaptic(onTap),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 46,
          decoration: BoxDecoration(
            color: selected ? AppColors.sky50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.slate200,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.sky500 : Colors.transparent,
                  border: selected
                      ? null
                      : Border.all(color: AppColors.slate300),
                ),
              ),
              const SizedBox(width: 8),
              AppText(
                label,
                size: 13,
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
