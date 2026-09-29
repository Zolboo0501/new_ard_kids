import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class VerifiedName extends StatelessWidget {
  const VerifiedName({super.key, required this.name, required this.detail});

  final String name;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Wrap(
        spacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          LineIcon(
            LineGlyph.checkCircle,
            size: 16,
            color: AppColors.emerald600,
          ),
          AppText(
            name,
            size: 12,
            weight: FontWeight.w600,
            color: AppColors.emerald600,
          ),
          AppText(detail, size: 12, color: AppColors.slate500),
        ],
      ),
    );
  }
}
