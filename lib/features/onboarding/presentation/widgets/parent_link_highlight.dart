import 'package:flutter/material.dart';

import '../../../../app/avatar.dart';
import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';
import 'parent_link_limit_row.dart';

/// The top of [ParentLinkScreen]: the teen's avatar and the parent's picture
/// joined by a link, then what the link changes (the daily limit and how
/// many transfers a day). [dad] picks the parent's picture: the character's
/// own mother or father, falling back to the companion's mom/dad sticker
/// and then a plain person glyph.
class ParentLinkHighlight extends StatelessWidget {
  const ParentLinkHighlight({super.key, required this.dad});

  final bool dad;

  static const _size = 60.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.sky50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Circle(
                  child: Image.asset(
                    appAvatar.value.portrait,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const _Link(),
                _Circle(child: _ParentPicture(dad: dad)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ParentLinkLimitRow(
            label: 'Өдрийн эрх',
            before: formatMnt(Limits.unlinkedDaily),
            after: formatMnt(Limits.dailyTransfer),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.sky100),
          const ParentLinkLimitRow(
            label: 'Гүйлгээ',
            before: '2 удаа',
            after: 'Хязгааргүй',
          ),
        ],
      ),
    );
  }
}

/// A round frame in the accent ring, on the card colour.
class _Circle extends StatelessWidget {
  const _Circle({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ParentLinkHighlight._size,
      height: ParentLinkHighlight._size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.sky500,
        shape: BoxShape.circle,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.card, width: 2),
        ),
        child: ClipOval(child: child),
      ),
    );
  }
}

/// A short dotted line with the link badge on it, between the two pictures.
class _Link extends StatelessWidget {
  const _Link();

  @override
  Widget build(BuildContext context) {
    final dots = AppColors.sky300;
    Widget dashes() => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(color: dots, shape: BoxShape.circle),
          ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dashes(),
          const SizedBox(width: 4),
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.emerald500,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.sky50, width: 3),
            ),
            child: LineIcon(
              LineGlyph.link,
              size: 14,
              color: AppColors.onBright,
            ),
          ),
          const SizedBox(width: 4),
          dashes(),
        ],
      ),
    );
  }
}

class _ParentPicture extends StatelessWidget {
  const _ParentPicture({required this.dad});

  final bool dad;

  @override
  Widget build(BuildContext context) {
    final glyph = Center(
      child: LineIcon(LineGlyph.profile, size: 28, color: AppColors.sky600),
    );
    // The character's own parent, where it has one; it fills the circle the
    // way the teen's portrait beside it does.
    if (appAvatar.value.parentFace(dad: dad) case final face?) {
      return Image.asset(
        face,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        cacheWidth: (ParentLinkHighlight._size * 3).round(),
        errorBuilder: (_, _, _) => glyph,
      );
    }
    // 14+ has no companion stickers (see `Stickers.onCards`).
    if (!Stickers.onCards) return glyph;
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Image.asset(
        dad ? Stickers.dad : Stickers.mom,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => glyph,
      ),
    );
  }
}
