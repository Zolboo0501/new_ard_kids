import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/onboarding_store.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../data/welcome_slide.dart';
import '../widgets/welcome_backdrop.dart';
import '../widgets/welcome_next_button.dart';
import '../widgets/welcome_slide_page.dart';

/// Optional, swipeable introduction. Remembered only on completion or skip.
/// Each slide is a bean character on its own soft backdrop, which fills the
/// screen and crossfades with the swipe. The copy is centred; under it
/// the dots sit on the left and one round arrow button on the right moves
/// on, and on the last slide opens sign-in; Алгасах skips straight to
/// sign-in too.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _continue({required bool register}) {
    unawaited(OnboardingStore.complete());
    context.go(register ? AppRoutes.register : AppRoutes.auth);
  }

  void _showPage(int index) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(index);
    } else {
      _pages.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == welcomeSlides.length - 1;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: WelcomeBackdrop(pages: _pages, page: _page),
          ),
          SafeArea(
            child: Column(
              children: [
                // Only the skip, tucked in the corner.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _continue(register: false),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(72, 48),
                      ),
                      child: AppText(
                        'Алгасах',
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: welcomeSlides.length,
                    onPageChanged: (index) => setState(() => _page = index),
                    itemBuilder: (context, index) => AnimatedBuilder(
                      animation: _pages,
                      builder: (context, _) => WelcomeSlidePage(
                        slide: welcomeSlides[index],
                        offset: _position - index,
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _pages,
                  builder: (context, _) => _footer(last),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The arrow on the round button: white on every slide, the lime's
  /// included, like a mark printed on the coloured disc.
  static const _arrow = Color(0xFFFFFFFF);

  /// The button and active dot colour for [p]: the accent, darkened (its
  /// lightness lowered, so the hue stays) only as far as the white arrow
  /// needs to stand out on it, 3:1, the bar for icons. The purple, pink and
  /// blue keep their own shade; the pale lime deepens a little.
  static Color _fill(AppPalette p) {
    double contrast(Color a, Color b) {
      final (la, lb) = (a.computeLuminance(), b.computeLuminance());
      return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
    }

    final hsl = HSLColor.fromColor(p.c500);
    for (var step = 0; step <= 20; step++) {
      final fill = hsl
          .withLightness((hsl.lightness - step * 0.02).clamp(0.0, 1.0))
          .toColor();
      if (contrast(fill, _arrow) >= 3) return fill;
    }
    return hsl.withLightness(0.3).toColor();
  }

  /// The accents of the slide in view and the next one, and how far the
  /// swipe is between them.
  (AppPalette, AppPalette, double) _palettes() {
    final position = _position.clamp(0.0, welcomeSlides.length - 1.0);
    final i = position.floor();
    return (
      AppPalette.of(welcomeSlides[i].accent),
      AppPalette.of(
        welcomeSlides[(i + 1).clamp(0, welcomeSlides.length - 1)].accent,
      ),
      position - i,
    );
  }

  /// The pager's position in pages, fractional mid-swipe.
  double get _position => _pages.hasClients && _pages.position.haveDimensions
      ? _pages.page ?? _page.toDouble()
      : _page.toDouble();

  /// The dots and the one round button, in the accent of the slide in
  /// view, blending into the next one's as the kid swipes.
  Widget _footer(bool last) {
    final (from, to, t) = _palettes();
    final fill = Color.lerp(_fill(from), _fill(to), t)!;
    return AdaptiveCenter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 24, 20),
        child: Row(
          children: [
            for (var i = 0; i < welcomeSlides.length; i++)
              Semantics(
                label: '${welcomeSlides.length} хуудасны ${i + 1}',
                selected: _page == i,
                button: true,
                child: InkResponse(
                  onTap: () => _showPage(i),
                  radius: 22,
                  child: SizedBox(
                    width: 36,
                    height: 44,
                    child: Center(
                      child: AnimatedContainer(
                        duration: Duration(
                          milliseconds: MediaQuery.disableAnimationsOf(context)
                              ? 0
                              : 200,
                        ),
                        width: _page == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _page == i
                              ? fill
                              : fill.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const Spacer(),
            WelcomeNextButton(
              label: last ? 'Эхлэх' : 'Дараах',
              progress: (_page + 1) / welcomeSlides.length,
              color: fill,
              foreground: _arrow,
              // The last slide hands over to sign-in.
              onPressed: () =>
                  last ? _continue(register: false) : _showPage(_page + 1),
            ),
          ],
        ),
      ),
    );
  }
}
