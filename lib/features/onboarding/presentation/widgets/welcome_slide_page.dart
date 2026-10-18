import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../data/welcome_slide.dart';

/// One welcome page: the slide's bean character centred over the copy (the
/// title with its key word in the slide's accent, and a short description,
/// both centred).
///
/// [offset] is how far the pager is from this page (0 when it is settled
/// here, ±1 a page away). The character drifts against the swipe and the
/// copy fades, so a swipe reads as depth rather than a flat slide.
class WelcomeSlidePage extends StatelessWidget {
  const WelcomeSlidePage({super.key, required this.slide, this.offset = 0});
  final WelcomeSlide slide;
  final double offset;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= AppLayout.splitMin;
      final p = AppPalette.of(slide.accent);
      final still = MediaQuery.disableAnimationsOf(context);
      final drift = still ? 0.0 : offset.clamp(-1.0, 1.0);
      final art = Transform.translate(
        offset: Offset(drift * constraints.maxWidth * 0.35, 0),
        child: Transform.scale(
          scale: 1 - drift.abs() * 0.12,
          child: Image.asset(
            slide.character,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            excludeFromSemantics: true,
          ),
        ),
      );
      // Centred under the picture on a phone, left-aligned beside it on a
      // wide window.
      final align = wide ? TextAlign.start : TextAlign.center;
      final copy = Opacity(
        opacity: (1 - drift.abs() * 1.6).clamp(0.0, 1.0),
        child: Column(
          crossAxisAlignment: wide
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Text.rich(
              _title(slide, p, wide ? 42 : 32),
              textAlign: align,
              semanticsLabel: slide.title.replaceAll('\n', ' '),
            ),
            const SizedBox(height: 12),
            AppText(
              slide.description,
              size: 16,
              height: 1.5,
              color: AppColors.slate500,
              textAlign: align,
            ),
          ],
        ),
      );
      if (wide) {
        return AdaptiveListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            Row(
              children: [
                Expanded(child: SizedBox(height: 420, child: art)),
                const SizedBox(width: 40),
                Expanded(child: copy),
              ],
            ),
          ],
        );
      }
      // The character gets the height the copy leaves. The picture and the
      // copy sit at the bottom of the page, just above the dots; any height
      // to spare opens up at the top. Large text scrolls.
      final artHeight = (constraints.maxHeight - 200).clamp(120.0, 400.0);
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - 24).clamp(0.0, double.infinity),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: artHeight, child: art),
              const SizedBox(height: 24),
              copy,
            ],
          ),
        ),
      );
    },
  );

  /// The title with [WelcomeSlide.highlight] in the accent ink.
  static TextSpan _title(WelcomeSlide slide, AppPalette p, double size) {
    TextStyle style(Color color) => inter(
      size: size,
      weight: FontWeight.w800,
      color: color,
    ).copyWith(height: 1.12, letterSpacing: -0.9);
    final title = slide.title;
    final at = title.indexOf(slide.highlight);
    if (at < 0) return TextSpan(text: title, style: style(AppColors.slate900));
    final end = at + slide.highlight.length;
    return TextSpan(
      style: style(AppColors.slate900),
      children: [
        TextSpan(text: title.substring(0, at)),
        TextSpan(text: title.substring(at, end), style: style(p.c600)),
        TextSpan(text: title.substring(end)),
      ],
    );
  }
}
