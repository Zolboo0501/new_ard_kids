import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One limit on [ParentLinkScreen]: its label, the value today, and the
/// value once a parent is linked.
class ParentLinkLimitRow extends StatelessWidget {
  const ParentLinkLimitRow({
    super.key,
    required this.label,
    required this.before,
    required this.after,
  });

  final String label;
  final String before;
  final String after;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: одоо $before, холбосны дараа $after',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: AppText(label, size: 14, color: AppColors.slate600),
            ),
            const SizedBox(width: 8),
            Text(
              before,
              style: moneyStyle(size: 14, color: AppColors.slate500),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: LineIcon(
                LineGlyph.arrowRight,
                size: 14,
                color: AppColors.slate400,
              ),
            ),
            Text(
              after,
              style: moneyStyle(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.slate900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
