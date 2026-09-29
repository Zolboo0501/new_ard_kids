import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One accent in "Харагдац": a disc of the accent as it looks on the current
/// canvas, ringed when chosen, with its name underneath.
class AccentSwatch extends StatelessWidget {
  const AccentSwatch({
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

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(choice);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.94,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? palette.c500 : Colors.transparent,
                  width: 2,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.c500,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 160),
                  opacity: selected ? 1 : 0,
                  child: LineIcon(
                    LineGlyph.check,
                    size: 20,
                    color: palette.onAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AppText(
              label,
              size: 12,
              weight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.slate900 : AppColors.slate500,
              textAlign: TextAlign.center,
              maxLines: 2,
              height: 1.2,
            ),
          ],
        ),
      ),
    );
  }
}
