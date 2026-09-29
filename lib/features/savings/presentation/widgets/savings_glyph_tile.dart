import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';

/// A line icon on a rounded tinted tile, for goal and history rows.
class SavingsGlyphTile extends StatelessWidget {
  const SavingsGlyphTile({
    super.key,
    required this.glyph,
    this.tone = BadgeTone.slate,
    this.size = 44,
  });

  final LineGlyph glyph;

  /// Tints the tile (`*50`) and the glyph (`*600`); slate is neutral.
  final BadgeTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      BadgeTone.slate => (AppColors.slate50, AppColors.slate800),
      _ => (tone.colors.$1, tone.colors.$2),
    };
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineIcon(glyph, size: size * 0.5, color: fg),
    );
  }
}
