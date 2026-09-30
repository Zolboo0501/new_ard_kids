import 'package:flutter/material.dart';

import '../../../../app/accounts.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One of the kid's accounts in Home's carousel: the account's glyph and
/// name, a short line about what it is for, and its masked number. It is an
/// account, not a bank card, so there is no chip or contactless mark; the
/// account's own colour lights the glyph and a soft corner glow.
class HomeAccountPanel extends StatelessWidget {
  const HomeAccountPanel({
    super.key,
    required this.label,
    required this.subtitle,
    required this.account,
    required this.icon,
    required this.accent,
    this.image,
    this.background,
    this.aspectRatio = 1.586,
  });

  final String label;
  final String subtitle;
  final String account;
  final LineGlyph icon;
  final Color accent;

  /// A picture drawn in place of [icon], such as the 3D Ард койн.
  final String? image;

  /// Card art filling the panel, such as the 10–13 fox's account cards,
  /// and the deep shade of the card's hue its text takes. The text then
  /// follows the art's sticker style (see [_ArtLabels]) in both modes, and
  /// the glyph tile is left out: the art shows the account.
  final ({String asset, Color ink})? background;

  /// Width over height; a bank card by default. Null fills the space the
  /// parent gives, as Home's carousel does to keep its height while the
  /// card spans more of the width.
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final art = background;
    final panel = Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // The art covers the whole card, trimmed at the sides; the
          // character stays in view on the right.
          if (art != null)
            Positioned.fill(
              child: Image.asset(
                art.asset,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                filterQuality: FilterQuality.high,
                excludeFromSemantics: true,
              ),
            )
          else
            // A faint wash of the account's colour from the top-left corner.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-1, -1),
                    radius: 1.2,
                    colors: [
                      accent.withValues(alpha: 0.16),
                      accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: art != null
                ? _ArtLabels(
                    label: label,
                    subtitle: subtitle,
                    account: account,
                    ink: art.ink,
                  )
                : SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: image != null
                                  ? Image.asset(
                                      image!,
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.contain,
                                      cacheWidth: 120,
                                      excludeFromSemantics: true,
                                    )
                                  : LineIcon(icon, size: 22, color: accent),
                            ),
                          ],
                        ),
                        const Spacer(),
                        AppText(
                          label,
                          size: 17,
                          weight: FontWeight.w700,
                          color: AppColors.slate900,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          subtitle,
                          size: 12,
                          weight: FontWeight.w500,
                          color: AppColors.slate500,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            maskIban(account),
                            maxLines: 1,
                            style:
                                inter(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: AppColors.slate900,
                                  letterSpacing: 0.6,
                                ).copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
    final ratio = aspectRatio;
    return ratio == null
        ? panel
        : AspectRatio(aspectRatio: ratio, child: panel);
  }
}

/// The text on an art card, drawn like the art's stickers: the account name
/// in Nunito Black, whose round heavy letters match the characters' thick
/// rounded outlines (it covers Mongolian Ө and Ү), in the card's deep hue
/// with the white outline the characters wear, so it holds up where a brush
/// stroke passes behind it; the purpose in the same hue, softer; and the
/// number on a white sticker pill.
class _ArtLabels extends StatelessWidget {
  const _ArtLabels({
    required this.label,
    required this.subtitle,
    required this.account,
    required this.ink,
  });

  final String label;
  final String subtitle;
  final String account;
  final Color ink;

  static const _white = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    const name = TextStyle(
      fontFamily: 'Nunito',
      fontSize: 22,
      fontWeight: FontWeight.w900,
      // Nunito's heaviest cut: the variable font's weight axis tops out at
      // 1000, past FontWeight.w900.
      fontVariations: [FontVariation.weight(1000)],
      height: 1.1,
      letterSpacing: -0.2,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The outline is the same text drawn first as a thick white stroke.
        Stack(
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: name.copyWith(
                color: null,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 5
                  ..strokeJoin = StrokeJoin.round
                  ..color = _white,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: name.copyWith(color: ink),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: inter(
            size: 12,
            weight: FontWeight.w600,
            color: ink.withValues(alpha: 0.8),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          decoration: BoxDecoration(
            color: _white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            maskIban(account),
            maxLines: 1,
            style: inter(
              size: 12,
              weight: FontWeight.w700,
              color: ink,
              letterSpacing: 0.4,
            ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ),
      ],
    );
  }
}
