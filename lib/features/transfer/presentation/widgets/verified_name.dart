import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';

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
        children: [
          AppText(
            name,
            size: 11,
            weight: FontWeight.w700,
            color: AppColors.emerald600,
          ),
          AppText(detail, size: 10, color: AppColors.slate400),
        ],
      ),
    );
  }
}
