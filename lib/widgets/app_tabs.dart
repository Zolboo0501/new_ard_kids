import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'value_switcher.dart';

/// One segment of an [AppTabs] control.
class AppTab {
  const AppTab(this.label, {this.icon});

  final String label;

  /// Drawn before the label when set.
  final IconData? icon;
}

/// How an [AppTabs] control is painted. The sliding-pill behaviour is the
/// same for every style; only the colours, radii and type differ, so each
/// screen keeps the look it had before the control was shared.
class AppTabsStyle {
  const AppTabsStyle({
    required this.trackColor,
    required this.trackRadius,
    required this.pillRadius,
    required this.labelSize,
    required this.selectedColor,
    required this.unselectedColor,
    this.trackBorder,
    this.pillColor,
    this.pillGradient,
    this.pillShadow,
    this.selectedWeight = FontWeight.w700,
    this.unselectedWeight = FontWeight.w700,
    this.verticalPadding = 9,
    this.iconSize = 16,
    this.dotColor = Colors.white,
    this.dotSize = 5,
  });

  final Color trackColor;
  final double trackRadius;
  final Color? trackBorder;

  final Color? pillColor;
  final Gradient? pillGradient;
  final double pillRadius;
  final List<BoxShadow>? pillShadow;

  final double labelSize;
  final Color selectedColor;
  final Color unselectedColor;
  final FontWeight selectedWeight;
  final FontWeight unselectedWeight;

  final double verticalPadding;
  final double iconSize;
  final Color dotColor;
  final double dotSize;

  /// Sky gradient pill on a slate track. The sign-in screen's mode switcher.
  static AppTabsStyle get pill => AppTabsStyle(
    trackColor: AppColors.slate100.withValues(alpha: 0.8),
    trackRadius: 999,
    trackBorder: AppColors.slate200.withValues(alpha: 0.5),
    pillGradient: LinearGradient(colors: [AppColors.sky500, AppColors.sky400]),
    pillRadius: 999,
    pillShadow: [
      BoxShadow(
        color: AppColors.sky500.withValues(alpha: 0.3),
        offset: const Offset(0, 2),
        blurRadius: 8,
      ),
    ],
    labelSize: 12,
    selectedColor: Colors.white,
    unselectedColor: AppColors.slate500,
  );

  /// White card pill on a sky track. The home screen's account tabs.
  static AppTabsStyle get card => AppTabsStyle(
    trackColor: AppColors.sky100.withValues(alpha: 0.6),
    trackRadius: 16,
    trackBorder: AppColors.sky100,
    pillColor: Colors.white,
    pillRadius: 12,
    pillShadow: const [
      BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
    ],
    labelSize: 13,
    selectedColor: AppColors.sky600,
    unselectedColor: AppColors.slate500,
    unselectedWeight: FontWeight.w600,
    dotColor: AppColors.sky500,
    dotSize: 7,
  );

  /// Solid sky pill on a slate track. The QR screen's scan/show tabs.
  static AppTabsStyle get solid => AppTabsStyle(
    trackColor: AppColors.slate200.withValues(alpha: 0.7),
    trackRadius: 16,
    pillColor: AppColors.sky500,
    pillRadius: 999,
    labelSize: 13,
    selectedColor: Colors.white,
    unselectedColor: AppColors.slate600,
    verticalPadding: 10,
    iconSize: 17,
  );
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
    this.style,
  });

  final List<AppTab> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  /// Shows a small dot after the selected tab's label.
  final bool dotOnActive;

  /// How the control is painted. Null means [AppTabsStyle.pill]; it cannot be
  /// the default argument because the presets are not compile-time constants.
  final AppTabsStyle? style;

  static const _duration = Duration(milliseconds: 280);

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? AppTabsStyle.pill;
    final count = tabs.length;
    // Maps the selected index onto Alignment's -1..1 axis. A single tab has
    // nowhere to travel, so it sits at the start.
    final x = count > 1 ? -1 + 2 * (index / (count - 1)) : -1.0;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: style.trackColor,
        borderRadius: BorderRadius.circular(style.trackRadius),
        border: style.trackBorder == null
            ? null
            : Border.all(color: style.trackBorder!),
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
                    borderRadius: BorderRadius.circular(style.pillRadius),
                    color: style.pillColor,
                    gradient: style.pillGradient,
                    boxShadow: style.pillShadow,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final (i, tab) in tabs.indexed) _buildTab(style, i, tab),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(AppTabsStyle style, int i, AppTab tab) {
    final selected = i == index;
    final color = selected ? style.selectedColor : style.unselectedColor;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // Only a real switch clicks; tapping the current tab is silent.
            if (!selected) HapticFeedback.selectionClick();
            onChanged(i);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: style.verticalPadding),
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
                        Icon(tab.icon, size: style.iconSize, color: value),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  // AnimatedDefaultTextStyle needs a plain Text child, so this
                  // is the one place a raw Text is correct over AppText; the
                  // style still comes from inter().
                  child: AnimatedDefaultTextStyle(
                    duration: _duration,
                    curve: appEmphasizedDecelerate,
                    style: inter(
                      size: style.labelSize,
                      weight: selected
                          ? style.selectedWeight
                          : style.unselectedWeight,
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
                    width: style.dotSize,
                    height: style.dotSize,
                    decoration: BoxDecoration(
                      color: style.dotColor,
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

/// The content pane belonging to an [AppTabs] control.
///
/// Implements the Material 3 "shared axis" transition: the outgoing pane
/// leaves along the axis of travel while the incoming one arrives from the
/// other side, and the two fades are *offset* rather than simultaneous.
///
/// That offset is the point. A plain [AnimatedSwitcher] cross-fades linearly,
/// so halfway through both panes sit at 50% opacity and the content looks like
/// it blinks out and comes back. Here the outgoing pane is gone before the
/// incoming one is much past invisible, so there is never a washed-out frame
/// and never a blank one.
///
/// Height is eased too, so panes of different lengths do not jolt the page.
class AppTabView extends StatefulWidget {
  const AppTabView({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 320),
  });

  /// The selected tab. Drives both the direction of travel and the key used
  /// to tell one pane from the next.
  final int index;

  final Widget child;
  final Duration duration;

  /// Fraction of [duration] the incoming pane waits before it starts to fade
  /// in, so the outgoing one is already gone.
  static const _incomingStart = 0.35;

  /// When a pane switched in with the default [duration] first becomes
  /// visible. Content inside the pane that animates on its own (e.g.
  /// [ListItemEntrance] rows) should start then, not while it's invisible.
  static const incomingDelay = Duration(milliseconds: 112);

  @override
  State<AppTabView> createState() => _AppTabViewState();
}

class _AppTabViewState extends State<AppTabView> {
  late int _previous = widget.index;

  @override
  void didUpdateWidget(AppTabView old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) _previous = old.index;
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return KeyedSubtree(key: ValueKey(widget.index), child: widget.child);
    }

    // Moving right through the tabs pushes content left, and vice versa.
    final sign = widget.index >= _previous ? 1.0 : -1.0;

    return AnimatedSize(
      duration: widget.duration,
      curve: appEmphasizedDecelerate,
      alignment: Alignment.topCenter,
      child: ValueSwitcher(
        value: widget.index,
        duration: widget.duration,
        // Incoming waits out the first third, by which time the outgoing pane
        // has already gone. Reversed for the outgoing child by AnimatedSwitcher.
        switchInCurve: const Interval(
          AppTabView._incomingStart,
          1,
          curve: appEmphasizedDecelerate,
        ),
        switchOutCurve: const Interval(
          AppTabView._incomingStart,
          1,
          curve: appEmphasizedDecelerate,
        ),
        layoutBuilder: (currentChild, previousChildren) => Stack(
          alignment: Alignment.topCenter,
          children: [
            // Positioned, so a taller outgoing pane cannot stretch the stack
            // while it leaves; only the current pane sets the height.
            for (final c in previousChildren)
              Positioned(top: 0, left: 0, right: 0, child: c),
            ?currentChild,
          ],
        ),
        transitionBuilder: (child, animation, incoming) {
          // Each pane animates from its own side back to rest; the outgoing
          // one runs this in reverse, so it exits the way the new one came.
          final from = Offset(0.14 * (incoming ? sign : -sign), 0);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(begin: from, end: Offset.zero).animate(animation),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
