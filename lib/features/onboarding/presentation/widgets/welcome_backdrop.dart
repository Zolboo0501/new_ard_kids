import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../data/welcome_slide.dart';

/// The welcome screen's full-screen background: each slide's backdrop,
/// crossfading with the swipe so the colours follow the page under the
/// finger. On the dark canvas the light art sits under a scrim of the page
/// colour, so the light text still reads.
class WelcomeBackdrop extends StatelessWidget {
  const WelcomeBackdrop({super.key, required this.pages, required this.page});

  final PageController pages;

  /// The settled page, used before the pager has laid out.
  final int page;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: AppColors.surface),
        AnimatedBuilder(
          animation: pages,
          builder: (context, _) {
            final position = pages.hasClients && pages.position.haveDimensions
                ? pages.page ?? page.toDouble()
                : page.toDouble();
            return Stack(
              fit: StackFit.expand,
              children: [
                for (final (i, slide) in welcomeSlides.indexed)
                  // Only the one or two pages in view are drawn.
                  if ((position - i).abs() < 1)
                    Opacity(
                      opacity: 1 - (position - i).abs(),
                      child: Image.asset(
                        slide.background,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        excludeFromSemantics: true,
                      ),
                    ),
              ],
            );
          },
        ),
        if (AppColors.isDark)
          ColoredBox(color: AppColors.surface.withValues(alpha: 0.85)),
      ],
    );
  }
}
