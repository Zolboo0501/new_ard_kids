import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One settings row: a line-icon tile, a title with an optional subtitle and
/// a trailing control. Tappable rows without a [trailing] get a chevron.
class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.glyph,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final LineGlyph glyph;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Rose tile and title, for "Гарах".
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final tileBg = destructive ? AppColors.rose50 : AppColors.slate50;
    final ink = destructive ? AppColors.rose600 : AppColors.slate800;
    final trailing =
        this.trailing ??
        (onTap == null || destructive
            ? null
            : LineIcon(
                LineGlyph.chevronRight,
                size: 20,
                color: AppColors.slate400,
              ));
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tileBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: LineIcon(glyph, size: 22, color: ink),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    title,
                    size: 15,
                    weight: FontWeight.w600,
                    color: destructive ? AppColors.rose600 : AppColors.slate900,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    AppText(subtitle!, size: 13, color: AppColors.slate500),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
          ],
        ),
      ),
    );
    if (onTap == null) return row;
    return Semantics(
      button: true,
      child: InkWell(onTap: withHaptic(onTap), child: row),
    );
  }
}
