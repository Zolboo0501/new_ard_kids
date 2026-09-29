import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One of the card's quick actions under the card: a glyph over a label.
/// [highlighted] fills it with the accent while it's the thing to undo
/// (Карт нээх on a frozen card).
class CardActionTile extends StatelessWidget {
  const CardActionTile({
    super.key,
    required this.glyph,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final LineGlyph glyph;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final ink = highlighted ? AppColors.onAccent : AppColors.slate900;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        color: highlighted ? AppColors.sky500 : AppColors.card,
        child: Column(
          children: [
            LineIcon(glyph, size: 22, color: ink),
            const SizedBox(height: 8),
            AppText(
              label,
              size: 12,
              weight: FontWeight.w600,
              color: ink,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
