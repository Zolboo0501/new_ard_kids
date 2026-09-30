import 'package:flutter/material.dart';

import '../app/avatar.dart';

/// A screen's summary card with the chosen character's sticker inside it,
/// on the right, centred vertically: on the whole card, or with [area] on
/// the card's top [area] points, for a card whose lower rows run full width
/// (stat rows under a divider), so it centres on the headline above them. [sticker] is a `Stickers.*` path;
/// pick one every 10–13 set has (avatar, card, coin, gift, goal, growth,
/// lesson, qr, report, study, success, transfer) so no character falls back
/// to the kids' art.
///
/// Where the age has no stickers of its own (14+, see [Stickers.onCards])
/// the card shows alone. The sticker sits over the card, so keep the card's
/// right side free of text where it stands.
class AvatarCardArt extends StatelessWidget {
  const AvatarCardArt({
    super.key,
    required this.sticker,
    required this.child,
    this.size = 96,
    this.alignY = 0,
    this.area,
  });

  final String sticker;
  final Widget child;
  final double size;
  final double alignY;
  final double? area;

  @override
  Widget build(BuildContext context) {
    if (!Stickers.onCards) return child;
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
}
