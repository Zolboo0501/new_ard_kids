import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class GroupHeader extends StatelessWidget {
  const GroupHeader({super.key, required this.label, this.badge});

  final String label;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              label,
              size: 12,
              weight: FontWeight.w700,
              color: AppColors.slate400,
              letterSpacing: 0.8,
            ),
          ),
          if (badge != null) StatusBadge(label: badge!),
        ],
      ),
    );
  }
}
