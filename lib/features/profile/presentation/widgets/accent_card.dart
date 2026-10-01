import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One accent in "Миний өнгө": a rounded card with the accent's name and a
/// radio, a hairline, then four steps of its scale as ringed dots. The
/// chosen one is outlined and glows in its own accent, with an "Идэвхтэй"
/// tag on its top edge.
/// Applies at once on tap, like the mode tiles.
class AccentCard extends StatelessWidget {
  const AccentCard({
    super.key,
    required this.choice,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppThemeChoice choice;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// How far the "Идэвхтэй" tag rises above the card's top edge; the list
  /// leaves at least this much room between cards.
  static const tagLift = 12.0;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(choice);
    final steps = [p.c500, p.c300, p.c100, p.c700];
    final card = AppColors.card;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.98,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: selected ? p.c500 : card, width: 2),
                // Only the chosen card glows, softly, in its own accent; the
                // others are flat like the app's other cards.
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: p.c500.withValues(alpha: 0.16),
                          blurRadius: 28,
                          spreadRadius: -4,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          label,
                          size: 17,
                          weight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _Radio(color: p.c500, selected: selected),
                    ],
                  ),
                  Divider(height: 28, thickness: 1, color: AppColors.line),
                  Row(
                    children: [
                      for (final (i, c) in steps.indexed) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(color: card, width: 3),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // The tag sits on the chosen card's top edge.
            if (selected)
              Positioned(
                top: -tagLift,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: p.c500,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: AppText(
                    'Идэвхтэй',
                    size: 12,
                    weight: FontWeight.w700,
                    color: p.onAccent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A radio drawn in the accent's own colour.
class _Radio extends StatelessWidget {
  const _Radio({required this.color, required this.selected});

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 26,
      height: 26,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? color : AppColors.slate300,
          width: 2,
        ),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: selected ? 1 : 0,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
