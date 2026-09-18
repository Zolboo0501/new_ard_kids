import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One segment of an [AppTabs] control.
class AppTab {
  const AppTab(this.label, {this.icon});

  final String label;

  /// Drawn before the label when set.
  final IconData? icon;
}

/// Segmented control: equal-width tabs in a track, with a single pill that
/// slides to the selected one rather than fading in and out in place.
///
/// ```dart
/// AppTabs(
///   tabs: const [AppTab('Данс'), AppTab('Нэхэмжлэх'), AppTab('Карт')],
///   index: _tab,
///   onChanged: (i) => setState(() => _tab = i),
/// )
/// ```
class AppTabs extends StatelessWidget {
  const AppTabs({
    super.key,
    required this.tabs,
    required this.index,
    required this.onChanged,
    this.dotOnActive = false,
  });

  final List<AppTab> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  /// Shows a small dot after the selected tab's label.
  final bool dotOnActive;

  static const _duration = Duration(milliseconds: 280);

  @override
  Widget build(BuildContext context) {
    final count = tabs.length;
    // Maps the selected index onto Alignment's -1..1 axis. A single tab has
    // nowhere to travel, so it sits at the start.
    final x = count > 1 ? -1 + 2 * (index / (count - 1)) : -1.0;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.slate100.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.slate200.withValues(alpha: 0.5)),
      ),
      child: Stack(
        children: [
          // One pill that travels between the segments.
          Positioned.fill(
            child: AnimatedAlign(
              duration: _duration,
              curve: appEmphasizedDecelerate,
              alignment: Alignment(x, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / count,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [AppColors.sky500, AppColors.sky400],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sky500.withValues(alpha: 0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [for (final (i, tab) in tabs.indexed) _buildTab(i, tab)],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int i, AppTab tab) {
    final selected = i == index;
    final color = selected ? Colors.white : AppColors.slate500;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(i),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (tab.icon != null) ...[
                  // Crossing the same colours as the label, so the icon and
                  // text change together as the pill passes under them.
                  TweenAnimationBuilder<Color?>(
                    duration: _duration,
                    curve: appEmphasizedDecelerate,
                    tween: ColorTween(end: color),
                    builder: (context, value, _) =>
                        Icon(tab.icon, size: 16, color: value),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  // AnimatedDefaultTextStyle needs a plain Text child, so this
                  // is the one place a raw Text is correct over AppText; the
                  // style still comes from comfortaa().
                  child: AnimatedDefaultTextStyle(
                    duration: _duration,
                    curve: appEmphasizedDecelerate,
                    style: comfortaa(
                      size: 12,
                      weight: FontWeight.w700,
                      color: color,
                    ),
                    child: Text(
                      tab.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (dotOnActive && selected) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Convenience for the common case of plain text tabs.
List<AppTab> appTabsFromLabels(List<String> labels) => [
  for (final l in labels) AppTab(l),
];
