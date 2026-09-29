import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';

/// A read-only detail as a label/value pair.
class PersonalInfoRow extends StatelessWidget {
  const PersonalInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;

  /// A control after the value (the register number's show/hide toggle).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 4, trailing == null ? 16 : 4, 4),
        child: Row(
          children: [
            AppText(label, size: 14, color: AppColors.slate500),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(
                value,
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.slate900,
                textAlign: TextAlign.right,
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
