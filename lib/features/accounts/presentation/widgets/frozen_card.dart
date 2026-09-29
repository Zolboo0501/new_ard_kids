import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// Greys the card out and stamps it "Түр хаасан" while it's frozen.
class FrozenCard extends StatelessWidget {
  const FrozenCard({super.key, required this.frozen, required this.child});

  final bool frozen;
  final Widget child;

  static const _grey = ColorFilter.matrix([
    0.33, 0.33, 0.33, 0, 0, //
    0.33, 0.33, 0.33, 0, 0,
    0.33, 0.33, 0.33, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static const _none = ColorFilter.matrix([
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ColorFiltered(colorFilter: frozen ? _grey : _none, child: child),
        IgnorePointer(
          child: AnimatedScale(
            scale: frozen ? 1 : 0.8,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: frozen ? 1 : 0,
              duration: const Duration(milliseconds: 160),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.85),
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LineIcon(
                      LineGlyph.snowflake,
                      size: 16,
                      color: AppColors.slate900,
                    ),
                    const SizedBox(width: 6),
                    AppText(
                      'Түр хаасан',
                      size: 12,
                      weight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
