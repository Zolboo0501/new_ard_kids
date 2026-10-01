import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/avatar.dart';
import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/social_initials_avatar.dart';

/// "Найз урих": the bonus both friends get, the invite code, and who has
/// joined.
class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  static const _code = 'TEMU26';

  /// (name, status line, joined)
  static const _invited = [
    ('Anar B.', '2026.09.14-нд нэгдсэн', true),
    ('Misheel T.', '2026.08.30-нд нэгдсэн', true),
    ('Tergel E.', 'Урилга илгээсэн', false),
  ];

  void _copy(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _code));
    showAppSnack(context, 'Урилгын код хуулагдлаа');
  }

  Widget _title(String text, {Widget? trailing}) => Row(
    children: [
      Expanded(
        child: AppText(
          text,
          size: 16,
          weight: FontWeight.w700,
          color: AppColors.slate900,
        ),
      ),
      ?trailing,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SubPageHeader(title: 'Найз урих', background: AppColors.surface),
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const _InvitePair(),
                  const SizedBox(height: 14),
                  // The bonus each of the two gets.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      AppText(
                        'Хоёулаа',
                        size: 15,
                        weight: FontWeight.w600,
                        color: AppColors.slate600,
                      ),
                      const SizedBox(width: 8),
                      BalanceText(
                        Limits.inviteBonus,
                        size: 34,
                        weight: FontWeight.w700,
                        space: false,
                        color: AppColors.emerald600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    'Найз чинь энэ кодоор бүртгүүлбэл та хоёр урамшуулал авна.',
                    size: 14,
                    color: AppColors.slate500,
                    height: 1.4,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _code,
                            style: moneyStyle(
                              size: 20,
                              weight: FontWeight.w600,
                              color: AppColors.slate900,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        SoftButton(
                          label: 'Хуулах',
                          leading: LineIcon(
                            LineGlyph.copy,
                            size: 18,
                            color: AppColors.sky600,
                          ),
                          height: 44,
                          border: Colors.transparent,
                          onPressed: () => _copy(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _HowToUse(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
              child: _title(
                'Урьсан найзууд',
                trailing: AppText(
                  '${_invited.length}',
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.slate500,
                ),
              ),
            ),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final (i, f) in _invited.indexed) ...[
                    if (i > 0) Divider(height: 1, color: AppColors.line),
                    ListItemEntrance(
                      id: f,
                      index: i,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            SocialInitialsAvatar(name: f.$1),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppText(
                                f.$1,
                                size: 15,
                                weight: FontWeight.w600,
                                color: AppColors.slate900,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                BalanceText(
                                  Limits.inviteBonus,
                                  sign: f.$3,
                                  space: false,
                                  size: 14,
                                  weight: FontWeight.w600,
                                  color: f.$3
                                      ? AppColors.emerald600
                                      : AppColors.slate400,
                                ),
                                const SizedBox(height: 4),
                                StatusBadge(
                                  label: f.$3
                                      ? 'Баталгаажсан'
                                      : 'Хүлээгдэж буй',
                                  tone: f.$3
                                      ? BadgeTone.emerald
                                      : BadgeTone.amber,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Урилга хуваалцах',
              onPressed: () => _copy(context),
            ),
          ]),
        ),
      ),
    );
  }
}

/// The teen's avatar and a friend, joined by a heart: who gets the bonus.
/// Under 10 and 10–13 the friend is the companion's "friends" sticker; 14+
/// (no companion stickers on cards) a plain person glyph.
class _InvitePair extends StatelessWidget {
  const _InvitePair();

  static const _size = 64.0;

  Widget _circle(Widget child) => Container(
    width: _size,
    height: _size,
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(color: AppColors.sky500, shape: BoxShape.circle),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.card, width: 2),
      ),
      child: ClipOval(child: child),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final glyph = Center(
      child: LineIcon(LineGlyph.personAdd, size: 28, color: AppColors.sky600),
    );
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _circle(
            Image.asset(
              appAvatar.value.portrait,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            // Friends together: a heart on a soft disc in the theme colour,
            // ringed like the two avatars.
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.sky50,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.sky200, width: 1.5),
              ),
              child: PlainLineIcons(
                child: LineIcon(
                  LineGlyph.heart,
                  size: 18,
                  color: AppColors.sky600,
                ),
              ),
            ),
          ),
          _circle(
            Stickers.onCards
                ? Padding(
                    padding: const EdgeInsets.all(3),
                    child: Image.asset(
                      Stickers.friends,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, _, _) => glyph,
                    ),
                  )
                : glyph,
          ),
        ],
      ),
    );
  }
}

/// How to use the code, in three short steps: each a numbered icon and a
/// few words, side by side.
class _HowToUse extends StatelessWidget {
  const _HowToUse();

  static const _steps = [
    (LineGlyph.copy, 'Кодоо хуулж найздаа илгээ'),
    (LineGlyph.personAdd, 'Найз чинь кодоор бүртгүүлнэ'),
    (LineGlyph.gift, 'Хоёулаа урамшуулал авна'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
            child: AppText(
              'Кодоо яаж ашиглах вэ?',
              size: 16,
              weight: FontWeight.w700,
              color: AppColors.slate900,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, (glyph, text)) in _steps.indexed)
                Expanded(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.sky50,
                              shape: BoxShape.circle,
                            ),
                            child: LineIcon(
                              glyph,
                              size: 24,
                              color: AppColors.sky600,
                            ),
                          ),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 20,
                              height: 20,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.sky500,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.card,
                                  width: 2,
                                ),
                              ),
                              child: AppText(
                                '${i + 1}',
                                size: 10,
                                weight: FontWeight.w700,
                                color: AppColors.onAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AppText(
                          text,
                          size: 12,
                          weight: FontWeight.w600,
                          color: AppColors.slate700,
                          height: 1.3,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
