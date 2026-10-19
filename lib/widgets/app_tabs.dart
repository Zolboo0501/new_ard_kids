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

  /// Accent pill in a card track. The sign-in screen's mode switcher.
  static AppTabsStyle get pill => AppTabsStyle(
    trackColor: AppColors.card,
    trackRadius: 999,
    pillColor: AppColors.sky500,
    pillRadius: 999,
    labelSize: 12,
    selectedColor: AppColors.onAccent,
    unselectedColor: AppColors.slate500,
  );

  /// Home's tabs; the same as [night].
  static AppTabsStyle get card => night;

  /// A raised pill in a quiet track. Home's look: on the dark canvas a
  /// lighter pill on the card, on the light canvas a white pill in a grey
  /// track.
  static AppTabsStyle get night => AppTabsStyle(
    trackColor: AppColors.isDark ? AppColors.card : AppColors.slate100,
    trackRadius: 16,
    pillColor: AppColors.isDark ? AppColors.slate50 : AppColors.card,
    pillRadius: 12,
    labelSize: 13,
    selectedColor: AppColors.slate900,
    unselectedColor: AppColors.slate500,
    unselectedWeight: FontWeight.w600,
    dotColor: AppColors.sky500,
    dotSize: 6,
  );

  /// Solid accent pill in a card track. The QR screen's scan/show tabs.
  static AppTabsStyle get solid => AppTabsStyle(
    trackColor: AppColors.card,
    trackRadius: 16,
    pillColor: AppColors.sky500,
    pillRadius: 999,
    labelSize: 13,
    selectedColor: AppColors.onAccent,
    unselectedColor: AppColors.slate600,
    verticalPadding: 10,
    iconSize: 17,
  );
}

/// Segmented control: equal-width tabs in a track, with a single pill that
/// slides to the selected one rather than fading in and out in place.
///
/// The pill can also be dragged: it follows the finger along the track and
/// on release settles on the nearest tab, or the next one its way on a
/// fling, like the floating bottom bar's disc.
///
/// ```dart
/// AppTabs(
///   tabs: const [AppTab('Данс'), AppTab('Нэхэмжлэх'), AppTab('Карт')],
///   index: _tab,
///   onChanged: (i) => setState(() => _tab = i),
/// )
/// ```
class AppTabs extends StatefulWidget {
  const AppTabs({
    super.key,
    required this.tabs,
    required this.index,
    required this.onChanged,
    this.dotOnActive = false,
    this.style,
    this.dragPosition,
  });

  final List<AppTab> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  /// Where the pill sits while the screen drags it from outside (a swipe on
  /// the tab's content), in tabs; it follows instead of animating. Null when
  /// no such drag is under way.
  final double? dragPosition;

  /// Shows a small dot after the selected tab's label.
  final bool dotOnActive;

  /// How the control is painted. Null means [AppTabsStyle.pill]; it cannot be
  /// the default argument because the presets are not compile-time constants.
  final AppTabsStyle? style;

  static const _duration = Duration(milliseconds: 280);

  /// How fast (logical px/s) a drag must end to count as a fling.
  static const _flingVelocity = 300.0;

  @override
  State<AppTabs> createState() => _AppTabsState();
}

class _AppTabsState extends State<AppTabs> {
  /// Where the pill sits while it is dragged, in tabs (fractions between
  /// them); null otherwise.
  double? _drag;

  /// The tab a released drag picked, until the parent rebuilds with it, so
  /// the pill doesn't swing back to the old tab for a frame in between.
  int? _target;

  /// One segment's width, from the last layout; drags move by it.
  double _segment = 1;

  @override
  void didUpdateWidget(AppTabs old) {
    super.didUpdateWidget(old);
    _target = null;
  }

  int get _last => widget.tabs.length - 1;

  void _onDragStart(DragStartDetails _) {
    setState(() => _drag = widget.index.toDouble());
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final drag = _drag;
    if (drag == null) return;
    setState(
      () => _drag = (drag + details.primaryDelta! / _segment).clamp(
        0,
        _last.toDouble(),
      ),
    );
  }

  void _onDragEnd(DragEndDetails details) {
    final from = widget.index;
    final v = details.primaryVelocity ?? 0;
    final next =
        (v.abs() >= AppTabs._flingVelocity
                ? from + (v > 0 ? 1 : -1)
                : (_drag ?? from).round())
            .clamp(0, _last);
    setState(() {
      _drag = null;
      if (next != from) _target = next;
    });
    if (next != from) {
      HapticFeedback.selectionClick();
      widget.onChanged(next);
    }
  }

  void _onDragCancel() => setState(() => _drag = null);

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? AppTabsStyle.pill;
    final count = widget.tabs.length;
    final drag = _drag ?? widget.dragPosition;
    final position = drag ?? (_target ?? widget.index).toDouble();
    // During a drag the tab nearest the pill takes the selected look.
    final selected = position.round();
    // Maps the pill's position onto Alignment's -1..1 axis. A single tab has
    // nowhere to travel, so it sits at the start.
    final x = count > 1 ? -1 + 2 * (position / (count - 1)) : -1.0;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: style.trackColor,
        borderRadius: BorderRadius.circular(style.trackRadius),
        border: style.trackBorder == null
            ? null
            : Border.all(color: style.trackBorder!),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _segment = constraints.maxWidth / count;
          return GestureDetector(
            onHorizontalDragStart: count > 1 ? _onDragStart : null,
            onHorizontalDragUpdate: count > 1 ? _onDragUpdate : null,
            onHorizontalDragEnd: count > 1 ? _onDragEnd : null,
            onHorizontalDragCancel: count > 1 ? _onDragCancel : null,
            child: _track(style, count, x, selected, dragging: drag != null),
          );
        },
      ),
    );
  }

  Widget _track(
    AppTabsStyle style,
    int count,
    double x,
    int selected, {
    required bool dragging,
  }) {
    return Stack(
      children: [
        // One pill that travels between the segments: under the finger
        // while dragged, eased into place otherwise.
        Positioned.fill(
          child: AnimatedAlign(
            duration: dragging ? Duration.zero : AppTabs._duration,
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
            for (final (i, tab) in widget.tabs.indexed)
              _buildTab(style, i, tab, selected: i == selected),
          ],
        ),
      ],
    );
  }

  Widget _buildTab(
    AppTabsStyle style,
    int i,
    AppTab tab, {
    required bool selected,
  }) {
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
            widget.onChanged(i);
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
                    duration: AppTabs._duration,
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
                    duration: AppTabs._duration,
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
                if (widget.dotOnActive && selected) ...[
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

/// Lets the content under an [AppTabs] be swiped through its tabs: left to
/// the next tab, right to the one before, the pill following the finger the
/// way the floating bottom bar's disc does.
///
/// The screen keeps the drag position ([onDrag]) and hands it to its
/// [AppTabs] as `dragPosition`. On release a fling moves one tab its way and
/// a slow drag settles on the tab nearest the pill. A fling past the first or
/// last tab calls [onPastStart] / [onPastEnd] (a shell tab hands it on to
/// the bar's neighbouring tab). Sideways lists inside the content sit deeper
/// and keep their own drags; this sits deeper than the shell's swipe, so it
/// wins over it.
///
/// ```dart
/// AppTabSwipe(
///   index: _tab,
///   count: 2,
///   onChanged: (i) => setState(() => _tab = i),
///   onDrag: (p) => setState(() => _tabDrag = p),
///   child: AppTabView(index: _tab, child: ...),
/// )
/// ```
class AppTabSwipe extends StatefulWidget {
  const AppTabSwipe({
    super.key,
    required this.index,
    required this.count,
    required this.onChanged,
    required this.onDrag,
    this.onPastStart,
    this.onPastEnd,
    required this.child,
  });

  final int index;
  final int count;
  final ValueChanged<int> onChanged;

  /// Where the pill should sit while a drag is under way, in tabs
  /// (fractions between them); null once it ends.
  final ValueChanged<double?> onDrag;

  final VoidCallback? onPastStart;
  final VoidCallback? onPastEnd;
  final Widget child;

  /// How much of the screen's width a drag covers to move one tab, as on
  /// the bottom bar.
  static const _perTab = 0.5;

  @override
  State<AppTabSwipe> createState() => _AppTabSwipeState();
}

class _AppTabSwipeState extends State<AppTabSwipe> {
  double? _drag;

  void _set(double? drag) {
    _drag = drag;
    widget.onDrag(drag);
  }

  void _onStart(DragStartDetails _) => _set(widget.index.toDouble());

  void _onUpdate(DragUpdateDetails details) {
    final drag = _drag;
    if (drag == null) return;
    final perTab = MediaQuery.sizeOf(context).width * AppTabSwipe._perTab;
    _set((drag - details.primaryDelta! / perTab).clamp(0, widget.count - 1.0));
  }

  void _onEnd(DragEndDetails details) {
    final from = widget.index;
    final v = details.primaryVelocity ?? 0;
    final next = v.abs() >= AppTabs._flingVelocity
        ? from + (v < 0 ? 1 : -1)
        : (_drag ?? from).round();
    _set(null);
    final past = next < 0
        ? widget.onPastStart
        : next >= widget.count
        ? widget.onPastEnd
        : null;
    if (past != null) {
      HapticFeedback.selectionClick();
      past();
    } else if (next != from && next >= 0 && next < widget.count) {
      HapticFeedback.selectionClick();
      widget.onChanged(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onStart,
      onHorizontalDragUpdate: _onUpdate,
      onHorizontalDragEnd: _onEnd,
      onHorizontalDragCancel: () => _set(null),
      child: widget.child,
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
