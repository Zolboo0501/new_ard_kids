import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class DashedAction extends StatelessWidget {
  const DashedAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      dashed: true,
      borderColor: AppColors.sky200,
      radius: 18,
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.sky600),
          const SizedBox(width: 6),
          Flexible(
            child: AppText(
              label,
              size: 12,
              weight: FontWeight.w700,
              color: AppColors.sky600,
            ),
          ),
        ],
      ),
    );
  }
}
