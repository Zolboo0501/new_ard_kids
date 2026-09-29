import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';

/// A card of settings rows separated by hairlines. [indent] lines the
/// dividers up with the row titles (72 for rows with an icon tile).
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children, this.indent = 70});

  final List<Widget> children;
  final double indent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, c) in children.indexed) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: indent,
                    color: AppColors.line,
                  ),
                c,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
