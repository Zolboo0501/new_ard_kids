import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/units.dart';
import 'account_glyph_tile.dart';

/// One way to earn points on "Урамшуулал": glyph tile, the offer, what it
/// pays, and a single affordance: a chevron when the row opens something,
/// or a [button] when the row is the action itself (claiming today's
/// points). A [done] offer shows a quiet check instead.
class RewardOfferTile extends StatelessWidget {
  const RewardOfferTile({
    super.key,
    required this.glyph,
    required this.title,
    required this.points,
    required this.onTap,
    this.button,
    this.done = false,
    this.doneLabel = 'Авсан',
  });

  final LineGlyph glyph;
  final String title;
  final int points;
  final VoidCallback? onTap;

  /// The label of an inline action button; `null` makes the row itself
  /// tappable, with a chevron.
  final String? button;
  final bool done;
  final String doneLabel;

  @override
  Widget build(BuildContext context) {
    final trailing = done
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LineIcon(LineGlyph.check, size: 16, color: AppColors.slate500),
              const SizedBox(width: 4),
              AppText(
                doneLabel,
                size: 13,
                weight: FontWeight.w500,
                color: AppColors.slate500,
              ),
            ],
          )
        : button != null
        ? SoftButton(
            label: button!,
            height: 40,
            background: AppColors.sky500,
            foreground: AppColors.onAccent,
            border: Colors.transparent,
            onPressed: onTap,
          )
        : LineIcon(LineGlyph.chevronRight, size: 18, color: AppColors.slate400);

    final row = ConstrainedBox(
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
                  Text(
                    formatUnits(points, pointUnit, sign: true),
                    style: moneyStyle(
                      size: 13,
                      weight: FontWeight.w500,
                      color: done ? AppColors.slate500 : AppColors.emerald600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );

    if (button != null || done) return row;
    return Semantics(
      button: true,
      label: '$title, ${formatUnits(points, pointUnit, sign: true)}',
      excludeSemantics: true,
      child: Pressable(onTap: onTap, scale: 0.99, child: row),
    );
  }
}
