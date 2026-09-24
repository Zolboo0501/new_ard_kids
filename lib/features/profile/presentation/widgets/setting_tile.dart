import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBackground,
  });

  final IconData icon;
  final BadgeTone tone;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackground;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, _) = tone.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: withHaptic(onTap),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground ?? bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 20, color: iconColor ?? fg),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, size: 13, weight: FontWeight.w700),
                const SizedBox(height: 2),
                AppText(subtitle, size: 11, color: AppColors.slate400),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}
