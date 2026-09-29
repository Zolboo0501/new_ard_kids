import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';

/// A category or action glyph in a rounded square: the accounts screens'
/// replacement for illustrated row icons.
class AccountGlyphTile extends StatelessWidget {
  const AccountGlyphTile(
    this.glyph, {
    super.key,
    this.tint,
    this.ink,
    this.size = 44,
  });

  final LineGlyph glyph;

  /// Default to `AppColors.slate50` and `AppColors.slate800`.
  final Color? tint;
  final Color? ink;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint ?? AppColors.slate50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineIcon(
        glyph,
        size: size * 0.5,
        color: ink ?? AppColors.slate800,
      ),
    );
  }
}
