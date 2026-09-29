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

  final LineGlyph icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      dashed: true,
      borderColor: Night.line,
      color: Colors.transparent,
      shadow: false,
      radius: 18,
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LineIcon(icon, size: 18, color: AppColors.sky500),
          const SizedBox(width: 6),
          Flexible(
            child: AppText(
              label,
              size: 12,
              weight: FontWeight.w700,
              color: AppColors.sky500,
            ),
          ),
        ],
      ),
    );
  }
}
