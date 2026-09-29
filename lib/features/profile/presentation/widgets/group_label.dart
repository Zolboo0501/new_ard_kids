import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';

/// Section title above a settings group, with an optional quiet note on the
/// right ("1 төхөөрөмж").
class GroupLabel extends StatelessWidget {
  const GroupLabel(this.text, {super.key, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Row(
        children: [
          Expanded(child: AppText(text, size: 16, weight: FontWeight.w700)),
          if (trailing != null)
            AppText(trailing!, size: 13, color: AppColors.slate500),
        ],
      ),
    );
  }
}
