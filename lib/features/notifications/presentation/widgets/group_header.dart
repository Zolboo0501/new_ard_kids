import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';

/// Day heading above a group of notifications, with an optional unread
/// count on the right.
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
          Expanded(child: AppText(label, size: 16, weight: FontWeight.w700)),
          if (badge != null)
            AppText(
              badge!,
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.sky600,
            ),
        ],
      ),
    );
  }
}
