import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One account in Home's list: the account's glyph in a quiet tile, its
/// name and a short line, and the balance. A locked account (no parent
/// linked yet) is muted and shows a small lock instead of a balance.
///
/// With [background] (a character's banner, see `accountRowArt`) the row
/// is taller and the banner fills its right half: the character stands
/// there with the chevron at the edge, the icon tile is dropped (the art is
/// the account's picture), and the balance moves under the name so the
/// text side stays clear of the art.
class AccountRow extends StatelessWidget {
  const AccountRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.image,
    this.amount,
    this.onTap,
    this.locked = false,
    this.background,
  });

  final String title;
  final String subtitle;
  final LineGlyph icon;

  /// A picture drawn in place of [icon], such as the 3D Ард койн.
  final String? image;
  final int? amount;
  final VoidCallback? onTap;
  final bool locked;

  /// A banner behind the row (its `ink`/`tint` are unused now the tile is
  /// dropped on banner rows).
  final ({String asset, Color ink, Color tint})? background;

  /// Two lines (name, balance) with the row's padding; the banner is
  /// fitted to this height.
  static const _bannerRowHeight = 72.0;

  @override
  Widget build(BuildContext context) {
    final art = background;
    final card = AppColors.card;
    final dark = AppColors.isDark;
    Widget row = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: art == null ? card : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // On a banner the art is the account's picture, so no icon tile.
          if (art == null) ...[
            ExcludeSemantics(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: image != null
                    ? Image.asset(
                        image!,
                        width: 28,
                        height: 28,
                        cacheWidth: 112,
                        color: locked ? AppColors.slate50 : null,
                        colorBlendMode: locked ? BlendMode.saturation : null,
                      )
                    : LineIcon(
                        icon,
                        size: 21,
                        color: locked ? AppColors.slate400 : AppColors.slate800,
                      ),
              ),
            ),
            const SizedBox(width: 12),
          ] else
            const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  size: art == null ? 14 : 15,
                  weight: FontWeight.w600,
                  color: locked ? AppColors.slate500 : AppColors.slate900,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // On a banner the art says what the account is; the row
                // shows the name and the balance only.
                if (art == null) ...[
                  const SizedBox(height: 2),
                  AppText(
                    subtitle,
                    size: 12,
                    color: AppColors.slate500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (art != null && amount != null && !locked) ...[
                  const SizedBox(height: 4),
                  BalanceText(
                    amount!,
                    size: 15,
                    weight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (locked)
            Semantics(
              label: 'Түгжээтэй',
              child: LineIcon(
                LineGlyph.lock,
                size: 18,
                color: AppColors.slate400,
              ),
            )
          else ...[
            // On a banner the balance is under the name instead.
            if (amount != null && art == null)
              BalanceText(
                amount!,
                size: 15,
                weight: FontWeight.w600,
                color: AppColors.slate900,
              ),
            if (onTap != null) ...[
              const SizedBox(width: 2),
              LineIcon(
                LineGlyph.chevronRight,
                size: 18,
                color: art == null ? AppColors.slate500 : AppColors.slate700,
              ),
            ],
          ],
        ],
      ),
    );
    if (art != null) {
      // A fixed height with the banner fitted to it against the right
      // edge, its left end fading into the card colour under the text.
      // (No LayoutBuilder here: an image inside one re-resolves on every
      // layout pass and overflows the stack.)
      row = SizedBox(
        height: _bannerRowHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: card)),
              Positioned.fill(
                child: ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(
                    colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
                    stops: [0.1, 0.45],
                  ).createShader(rect),
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    art.asset,
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.centerRight,
                    filterQuality: FilterQuality.high,
                    excludeFromSemantics: true,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
              // The name's side stays clear of the art; on the dark canvas a
              // scrim keeps the light text readable.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: dark ? card.withValues(alpha: 0.7) : null,
                    gradient: LinearGradient(
                      colors: [
                        card.withValues(alpha: dark ? 0.85 : 0.6),
                        card.withValues(alpha: 0),
                      ],
                      stops: const [0.35, 0.6],
                    ),
                  ),
                ),
              ),
              Center(child: row),
            ],
          ),
        ),
      );
    }
    if (onTap == null) return row;
    return Pressable(onTap: onTap!, scale: 0.98, child: row);
  }
}
