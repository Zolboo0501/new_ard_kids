import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../app/avatar.dart';
import '../features/home/data/card_art.dart';
import '../theme/app_theme.dart';

/// A screen's summary card in the chosen character's art.
///
/// Where the character has card art (`accountCardArt`, the 10–13 fox, bear,
/// rabbit and cat), the card's own background is replaced by the art for
/// [account]: the character stays in view on the right, and the text side
/// is frosted glass (the art blurred, under a wash of the card colour) so
/// the words read clearly. On the
/// dark canvas the art sits under a scrim so light text still reads. The
/// card inside (`AppCard`, `AccountHeroPanel`) goes transparent on its own
/// by reading [artUnder].
///
/// Otherwise (under 10, whose sets have no card art) the [sticker], a
/// `Stickers.*` path, stands inside the card on the right, centred
/// vertically: on the whole card, or with [area] on the card's top [area]
/// points, for a card whose lower rows run full width. Pick a sticker every
/// set has (avatar, card, coin, gift, goal, growth, lesson, qr, report,
/// study, success, transfer). 14+ has neither (see [Stickers.onCards]) and
/// shows the plain card.
class AvatarCardArt extends StatelessWidget {
  const AvatarCardArt({
    super.key,
    required this.sticker,
    required this.child,
    this.account,
    this.size = 96,
    this.alignY = 0,
    this.area,
    this.radius = 16,
  });

  final String sticker;
  final Widget child;

  /// The account (an `Accounts.*` IBAN) whose card art backs the card.
  final String? account;
  final double size;
  final double alignY;
  final double? area;

  /// The card's corner radius, which the art is clipped to.
  final double radius;

  /// Whether the card at [context] sits on art and should draw no background
  /// of its own.
  static bool artUnder(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ArtScope>() != null;

  @override
  Widget build(BuildContext context) {
    if (!Stickers.onCards) return child;
    final art = account == null ? null : accountCardArt(account!);
    if (art != null) return _artCard(art);
    return Stack(
      children: [
        // Summary cards span the width; a card that sizes to its content
        // (a centred amount) would put the sticker on its text.
        SizedBox(width: double.infinity, child: child),
        Positioned(
          top: 8,
          right: 8,
          left: 0,
          bottom: area == null ? 8 : null,
          height: area == null ? null : area! - 16,
          child: IgnorePointer(
            child: Align(
              alignment: Alignment(1, alignY),
              child: Image.asset(
                sticker,
                width: size,
                height: size,
                fit: BoxFit.contain,
                cacheWidth: (size * 3).round(),
                filterQuality: FilterQuality.high,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _artCard(String art) {
    final card = AppColors.card;
    final dark = AppColors.isDark;
    final band = area;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: card)),
          // Frosted glass under the text: the same art, blurred, across the
          // whole art area, so the words sit on a soft haze of its colours
          // instead of on the busy picture.
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            bottom: band == null ? 0 : null,
            height: band,
            // Clipped: a blur paints past its own box, which would spill a
            // coloured strip under a band's rows.
            child: ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: 16,
                  sigmaY: 16,
                  tileMode: TileMode.clamp,
                ),
                child: Image.asset(
                  art,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
          // The art fills the card, or only its top [area] band on a card
          // with rows below, scaled to the band's height and kept to the
          // right so the character stands beside the headline, not under
          // the rows.
          Positioned(
            top: 0,
            right: 0,
            left: band == null ? 0 : null,
            bottom: band == null ? 0 : null,
            height: band,
            // The art's left edge fades out, so a band narrower than the
            // card doesn't cut a hard line into it.
            child: ShaderMask(
              // On a whole-card art the text runs further right (a centred
              // amount, a full-width stat row), so the character comes in
              // later there.
              shaderCallback: (rect) => LinearGradient(
                colors: const [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
                stops: band == null ? const [0.55, 0.9] : const [0, 0.45],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                art,
                fit: band == null ? BoxFit.cover : BoxFit.fitHeight,
                alignment: Alignment.centerRight,
                filterQuality: FilterQuality.high,
                excludeFromSemantics: true,
              ),
            ),
          ),
          // A scrim on the dark canvas, the wash in from the text side, and
          // on a band its soft lower edge.
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            bottom: band == null ? 0 : null,
            height: band,
            child: DecoratedBox(
              decoration: BoxDecoration(
                // The frost's wash: strongest under the text, clear by the
                // character. A BoxDecoration's colour is ignored under a
                // gradient, so on the dark canvas the dimming is part of the
                // gradient: near opaque under the text, still dimming the
                // character so light text never sits on bright art.
                gradient: LinearGradient(
                  colors: dark
                      ? [
                          card.withValues(alpha: 0.94),
                          card.withValues(alpha: 0.85),
                          card.withValues(alpha: 0.35),
                        ]
                      : [
                          card.withValues(alpha: 0.72),
                          card.withValues(alpha: 0.5),
                          card.withValues(alpha: 0),
                        ],
                  stops: band == null
                      ? const [0, 0.68, 0.9]
                      : const [0, 0.42, 0.7],
                ),
              ),
              child: band == null
                  ? null
                  : Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [card.withValues(alpha: 0), card],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          _ArtScope(
            child: SizedBox(width: double.infinity, child: child),
          ),
        ],
      ),
    );
  }
}

/// Marks the subtree that sits on card art (see [AvatarCardArt.artUnder]).
class _ArtScope extends InheritedWidget {
  const _ArtScope({required super.child});

  @override
  bool updateShouldNotify(_ArtScope oldWidget) => false;
}
