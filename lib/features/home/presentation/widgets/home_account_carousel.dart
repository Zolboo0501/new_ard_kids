import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';
import '../../data/home_account.dart';
import 'home_account_card.dart';

/// Home's row of account cards. One card sits in the centre with the next
/// one showing at the edge; swiping, or tapping a card at the side, brings
/// another account to the centre and reports it through [onPageChanged].
class HomeAccountCarousel extends StatefulWidget {
  const HomeAccountCarousel({
    super.key,
    required this.accounts,
    required this.mascotName,
    required this.onPageChanged,
  });

  final List<HomeAccount> accounts;
  final String mascotName;
  final ValueChanged<int> onPageChanged;

  @override
  State<HomeAccountCarousel> createState() => _HomeAccountCarouselState();
}

class _HomeAccountCarouselState extends State<HomeAccountCarousel> {
  /// The width a card takes in the row, the gaps at its sides included.
  static const _pitch = 276.0;
  static const _gap = 10.0;

  /// How far the row runs past the page's side padding, so the cards at the
  /// sides reach the edge of the screen instead of being cut at the gutter.
  static const _bleed = 16.0;

  // Room above and below the card for its shadow.
  static const _top = 8.0;
  static const _bottom = 22.0;

  /// How much of each end fades out where the row stops short of the
  /// screen's edges.
  static const _fade = 28.0;

  PageController? _pages;
  double _fraction = 1;
  int _page = 0;

  /// The controller for a row [width] wide. A card keeps its width whatever
  /// the screen's, so the share of the row it takes changes with the width
  /// (an iPad turning), and that needs a new controller.
  PageController _controllerFor(double width) {
    final fraction = (_pitch / width).clamp(0.1, 1.0);
    final current = _pages;
    if (current != null && fraction == _fraction) return current;
    if (current != null) {
      // Still attached to the PageView until this build is done.
      WidgetsBinding.instance.addPostFrameCallback((_) => current.dispose());
    }
    _fraction = fraction;
    return _pages = PageController(
      initialPage: _page,
      viewportFraction: fraction,
    );
  }

  @override
  void dispose() {
    _pages?.dispose();
    super.dispose();
  }

  /// How far card [i] sits from the centre of the carousel, in pages:
  /// 0 when it's showing, ±1 one swipe away. Before the PageView has a size
  /// (first frame) the settled page is used.
  double _pageOffset(PageController pages, int i) {
    final position = pages.hasClients ? pages.position : null;
    final page = position != null && position.haveDimensions
        ? pages.page ?? _page.toDouble()
        : _page.toDouble();
    return i - page;
  }

  void _show(PageController pages, int i) {
    if (MediaQuery.disableAnimationsOf(context)) {
      pages.jumpToPage(i);
    } else {
      pages.animateToPage(
        i,
        duration: const Duration(milliseconds: 420),
        curve: appEmphasizedDecelerate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const height = _top + HomeAccountCard.height + _bottom;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth + 2 * _bleed;
        final pages = _controllerFor(width);
        // Beside another pane (iPad) the row ends mid-screen, so the cards
        // at its sides fade away instead of being cut off.
        final fades = width < MediaQuery.sizeOf(context).width - 1;
        return SizedBox(
          height: height,
          child: OverflowBox(
            minWidth: width,
            maxWidth: width,
            child: Stack(
              children: [
                const Positioned.fill(child: _Glow()),
                _EdgeFade(
                  width: fades ? _fade / width : 0,
                  child: PageView.builder(
                    controller: pages,
                    itemCount: widget.accounts.length,
                    onPageChanged: (i) {
                      setState(() => _page = i);
                      widget.onPageChanged(i);
                    },
                    // Each card follows the swipe: the one leaving shrinks
                    // and pales while the next grows in.
                    itemBuilder: (_, i) => AnimatedBuilder(
                      animation: pages,
                      builder: (context, _) {
                        final offset = _pageOffset(pages, i);
                        final t = offset.abs().clamp(0.0, 1.0);
                        return Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              _gap,
                              _top,
                              _gap,
                              0,
                            ),
                            child: Transform.scale(
                              scale: 1 - 0.08 * t,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: i == _page
                                    ? null
                                    : withHaptic(() => _show(pages, i)),
                                // Paled with a wash of the page colour, not an
                                // Opacity: see the shell's fade in CLAUDE.md.
                                child: DecoratedBox(
                                  position: DecorationPosition.foreground,
                                  decoration: BoxDecoration(
                                    color: kPageBackground.withValues(
                                      alpha: 0.5 * t,
                                    ),
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                  child: HomeAccountCard(
                                    account: widget.accounts[i],
                                    mascotName: widget.mascotName,
                                    shift: offset,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Fades both ends of [child] to nothing over [width] of its own width;
/// 0 leaves it as it is.
class _EdgeFade extends StatelessWidget {
  const _EdgeFade({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (width == 0) return child;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => LinearGradient(
        colors: const [
          Color(0x00000000),
          Color(0xFF000000),
          Color(0xFF000000),
          Color(0x00000000),
        ],
        stops: [0, width, 1 - width, 1],
      ).createShader(rect),
      child: child,
    );
  }
}

/// The soft light in the theme accent behind the card in the centre.
class _Glow extends StatelessWidget {
  const _Glow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Transform(
          alignment: Alignment.center,
          // A circle stretched sideways, wider than the card.
          transform: Matrix4.diagonal3Values(1.9, 1.05, 1),
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.sky300.withValues(alpha: 0.55),
                  AppColors.sky300.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
