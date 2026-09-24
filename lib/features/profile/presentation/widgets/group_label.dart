import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';

class GroupLabel extends StatelessWidget {
  const GroupLabel(this.text, {super.key, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text,
              size: 12,
              weight: FontWeight.w700,
              color: AppColors.slate400,
              letterSpacing: 0.6,
            ),
          ),
          if (trailing != null)
            AppText(
              trailing!,
              size: 11,
              weight: FontWeight.w500,
              color: AppColors.sky600,
            ),
        ],
      ),
    );
  }
}
