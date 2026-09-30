import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One accent in "Харагдац": a row card with the accent's glyph tile, its
/// name and a line about it, four steps of its scale as dots, and a radio.
/// The chosen one is outlined in its own accent and tagged "Идэвхтэй".
/// Applies at once on tap, like the mode tiles.
class AccentCard extends StatelessWidget {
  const AccentCard({
    super.key,
    required this.choice,
    required this.label,
    required this.subtitle,
    required this.description,
    required this.glyph,
    required this.selected,
    required this.onTap,
  });

  final AppThemeChoice choice;
  final String label;

  /// The English name, after [label] in brackets.
  final String subtitle;
  final String description;
  final LineGlyph glyph;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(choice);
    final steps = [p.c500, p.c300, p.c100, p.c700];
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.98,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? p.c500 : AppColors.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: p.c500,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: LineIcon(glyph, size: 24, color: p.onAccent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: label,
                            style: inter(
                              size: 15,
                              weight: FontWeight.w700,
                              color: AppColors.slate900,
                            ),
                            children: [
                              TextSpan(
                                text: '  $subtitle',
                                style: inter(
                                  size: 13,
                                  weight: FontWeight.w500,
                                  color: AppColors.slate400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        AppText(
                          description,
                          size: 13,
                          color: AppColors.slate500,
                          height: 1.35,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _Radio(color: p.c500, selected: selected),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final (i, c) in steps.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.line),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (selected)
                    AppText(
                      'Идэвхтэй',
                      size: 12,
                      weight: FontWeight.w700,
                      color: p.c600,
                    ),
                ],
              ),
            ],
          ),
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
      width: 22,
      height: 22,
      padding: const EdgeInsets.all(4),
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
