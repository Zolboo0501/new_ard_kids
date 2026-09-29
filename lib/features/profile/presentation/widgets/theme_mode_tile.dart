import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One of the light / dark / system choices in "Харагдац": a small picture
/// of the canvas with two cards on it, and the mode's name. The system tile
/// is split down the middle, light on the left and dark on the right.
class ThemeModeTile extends StatelessWidget {
  const ThemeModeTile({
    super.key,
    required this.mode,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppBrightness mode;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.sky500;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.97,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 112,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? accent : AppColors.line,
                  width: selected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: switch (mode) {
                  AppBrightness.light => const _Canvas(dark: false),
                  AppBrightness.dark => const _Canvas(dark: true),
                  AppBrightness.system => const Row(
                    children: [
                      Expanded(child: _Canvas(dark: false)),
                      Expanded(child: _Canvas(dark: true)),
                    ],
                  ),
                },
              ),
            ),
            const SizedBox(height: 10),
            AppText(
              label,
              size: 13,
              weight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.slate900 : AppColors.slate500,
            ),
          ],
        ),
      ),
    );
  }
}

class _Canvas extends StatelessWidget {
  const _Canvas({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.modePreview(dark);
    final accent = AppPalette.of(appThemeChoice.value, dark: dark).c500;
    Widget bar(double width, Color color, {double height = 6}) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
    return ColoredBox(
      color: c.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bar(28, c.text.withValues(alpha: 0.8)),
            const SizedBox(height: 8),
            Container(
              height: 34,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: c.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [bar(22, c.line), bar(34, c.text, height: 7)],
              ),
            ),
            const Spacer(),
            bar(double.infinity, accent, height: 12),
          ],
        ),
      ),
    );
  }
}
