import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../data/welcome_slide.dart';

class WelcomeSlidePage extends StatelessWidget {
  const WelcomeSlidePage({super.key, required this.slide});
  final WelcomeSlide slide;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= AppLayout.splitMin;
      final art = Image.asset(
        slide.asset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        excludeFromSemantics: true,
      );
      final copy = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            slide.title,
            size: wide ? 42 : 34,
            height: 1.12,
            letterSpacing: -0.9,
            weight: FontWeight.w800,
            color: AppColors.slate900,
          ),
          const SizedBox(height: 18),
          AppText(
            slide.description,
            size: 16,
            height: 1.5,
            color: AppColors.slate600,
          ),
        ],
      );
      return AdaptiveListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          if (wide)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                children: [
                  Expanded(child: SizedBox(height: 380, child: art)),
                  const SizedBox(width: 40),
                  Expanded(child: copy),
                ],
              ),
            )
          else ...[
            SizedBox(
              height: (constraints.maxHeight - 250).clamp(120.0, 340.0),
              child: art,
            ),
            const SizedBox(height: 24),
            copy,
          ],
        ],
      );
    },
  );
}
