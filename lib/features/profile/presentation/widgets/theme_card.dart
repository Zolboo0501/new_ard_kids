import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class ThemeCard extends StatelessWidget {
  const ThemeCard({
    super.key,
    required this.title,
    required this.description,
    required this.tag,
    required this.palette,
    required this.icon,
    required this.selected,
    required this.active,
    required this.onTap,
  });

  final String title;
  final String description;
  final String tag;
  final AppPalette palette;
  final IconData icon;
  final bool selected;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = palette.c500;
    // The night palette the theme paints: accent fill, dark tint, tinted
    // line and the light accent ink.
    final swatches = [palette.c500, palette.c50, palette.c200, palette.c700];
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        scale: 0.98,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? accent : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: palette.c100,
                    ),
                    child: Icon(icon, color: accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppText(
                                title,
                                size: 13,
                                weight: FontWeight.w700,
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              width: 20,
                              height: 20,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? accent : AppColors.slate300,
                                  width: 2,
                                ),
                              ),
                              child: selected
                                  ? DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: accent,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          description,
                          size: 12,
                          color: AppColors.slate400,
                        ),
                        const Divider(height: 22, color: AppColors.slate100),
                        Row(
                          children: [
                            for (final c in swatches)
                              Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.slate300,
                                    width: 1,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            Flexible(
                              flex: 4,
                              child: AppText(
                                tag,
                                size: 11,
                                weight: FontWeight.w600,
                                color: palette.c600,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (active)
              Positioned(
                top: -10,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: AppText(
                    'Идэвхтэй',
                    size: 10,
                    weight: FontWeight.w700,
                    color: palette.onAccent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
