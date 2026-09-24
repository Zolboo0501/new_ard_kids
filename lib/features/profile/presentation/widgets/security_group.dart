import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';
import 'setting_tile.dart';

class SecurityGroup extends StatelessWidget {
  const SecurityGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 24,
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.slate100,
      child: Column(
        children: [
          for (final (i, c) in children.indexed) ...[
            if (i > 0 && c is SettingTile)
              const Divider(height: 20, color: AppColors.slate100),
            c,
          ],
        ],
      ),
    );
  }
}
