import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import 'account_glyph_tile.dart';

/// A tappable row that opens another screen: glyph tile, title over a
/// secondary line, and a chevron.
class RewardsShortcutRow extends StatelessWidget {
  const RewardsShortcutRow({
    super.key,
    required this.glyph,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final LineGlyph glyph;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title, $subtitle',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.99,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                AccountGlyphTile(
                  glyph,
                  tint: AppColors.sky50,
                  ink: AppColors.sky600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(title, size: 14, weight: FontWeight.w600),
                      const SizedBox(height: 2),
                      AppText(subtitle, size: 12, color: AppColors.slate500),
                    ],
                  ),
                ),
                LineIcon(
                  LineGlyph.chevronRight,
                  size: 18,
                  color: AppColors.slate400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
