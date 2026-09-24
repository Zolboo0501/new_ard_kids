import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';

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
                  color: AppColors.slate900.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.ac_unit_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    AppText(
                      'Түр хаасан',
                      size: 12,
                      weight: FontWeight.w700,
                      color: Colors.white,
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
