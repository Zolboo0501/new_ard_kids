import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Builds and owns the curved slices of a staggered entrance.
///
/// A screen keeps one of these beside its [AnimationController], asks for a
/// slice per element, and calls [dispose] from its own `dispose`. Building the
/// slices once matters: a screen that calls `setState` on every keystroke
/// would otherwise allocate a fresh [CurvedAnimation] per element per frame.
///
/// ```dart
/// late final _stagger = EntranceStagger(_entrance);
/// late final _title = _stagger.slice(0.1);
/// ```
class EntranceStagger {
  EntranceStagger(this.controller);

  final AnimationController controller;
  final _slices = <CurvedAnimation>[];

  /// A slice beginning at [start] (a fraction of the whole entrance) and
  /// running for [span]. Slices are meant to overlap, so the elements flow
  /// into one another instead of arriving one at a time.
  Animation<double> slice(double start, {double span = 0.62}) {
    final curved = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start,
        (start + span).clamp(0.0, 1.0),
        curve: appEmphasizedDecelerate,
      ),
    );
    _slices.add(curved);
    return curved;
  }

  void dispose() {
    for (final s in _slices) {
      s.dispose();
    }
    _slices.clear();
  }
}

/// One element of a staggered entrance: fades in while rising by [offsetY]
/// pixels over its slice [t] (see [EntranceStagger]).
///
/// The rise is a paint-time transform rather than a layout change, so a
/// running entrance can never shift a scroll extent or cause an overflow.
class Entrance extends StatelessWidget {
  const Entrance({
    super.key,
    required this.t,
    required this.child,
    this.offsetY = 16,
    this.scaleFrom,
  });

  /// This element's already-curved slice of the entrance.
  final Animation<double> t;

  /// How far the element rises into place.
  final double offsetY;

  /// When set, the element also scales up from this factor.
  final double? scaleFrom;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: t,
      // `child` is built by the caller and handed to the builder, so a running
      // entrance repaints without rebuilding the subtree underneath it.
      child: child,
      builder: (context, child) {
        final v = t.value;
        Widget result = Transform.translate(
          offset: Offset(0, offsetY * (1 - v)),
          child: child,
        );
        if (scaleFrom != null) {
          result = Transform.scale(
            scale: scaleFrom! + (1 - scaleFrom!) * v,
            child: result,
          );
        }
        // RenderOpacity paints straight through at 1.0, so leaving this in
        // costs nothing once the entrance has settled.
        return Opacity(opacity: v, child: result);
      },
    );
  }
}

/// Gives a whole screen a staggered entrance with no per-screen setup: wrap
/// the body in an [EntranceScope] and its list in [EntranceItem.list].
///
/// ```dart
/// body: EntranceScope(
///   child: ListView(children: EntranceItem.list([header, card, button])),
/// ),
/// ```
///
/// The scope owns one controller and plays it once when the screen opens.
/// Items built after that (scrolled into view later, or rebuilt) are simply
/// shown, so nothing replays mid-scroll. With reduced motion it starts done.
class EntranceScope extends StatefulWidget {
  const EntranceScope({super.key, required this.child});

  final Widget child;

  static const duration = Duration(milliseconds: 650);

  @override
  State<EntranceScope> createState() => _EntranceScopeState();
}

class _EntranceScopeState extends State<EntranceScope>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: EntranceScope.duration,
  );
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// [ListItemEntrance] ids already shown under this scope.
  final _seen = <Object>{};

  @override
  Widget build(BuildContext context) => _EntranceController(
    controller: _controller,
    seen: _seen,
    child: widget.child,
  );
}

class _EntranceController extends InheritedWidget {
  const _EntranceController({
    required this.controller,
    required this.seen,
    required super.child,
  });

  final AnimationController controller;
  final Set<Object> seen;

  @override
  bool updateShouldNotify(_EntranceController old) =>
      old.controller != controller;
}

/// The [index]th element of an [EntranceScope]'s entrance. Outside a scope it
/// just shows [child].
class EntranceItem extends StatefulWidget {
  const EntranceItem({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  /// Stagger between neighbouring items, as a fraction of the entrance.
  static const _step = 0.07;

  /// Later items all start by here, so a long list doesn't trail on.
  static const _lastStart = 0.42;

  /// Wraps each of [children] in an [EntranceItem], numbering them in order.
  /// Bare spacers (`SizedBox` without a child) are left as they are and don't
  /// take a slot in the stagger.
  static List<Widget> list(List<Widget> children) {
    var i = 0;
    return [
      for (final c in children)
        if (c is SizedBox && c.child == null)
          c
        else
          EntranceItem(index: i++, child: c),
    ];
  }

  @override
  State<EntranceItem> createState() => _EntranceItemState();
}

class _EntranceItemState extends State<EntranceItem> {
  CurvedAnimation? _t;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_t != null) return;
    final controller = context
        .dependOnInheritedWidgetOfExactType<_EntranceController>()
        ?.controller;
    // Built after the entrance finished (or with no scope): nothing to play.
    if (controller == null || controller.isCompleted) return;
    final start = (widget.index * EntranceItem._step).clamp(
      0.0,
      EntranceItem._lastStart,
    );
    _t = CurvedAnimation(
      parent: controller,
      curve: Interval(start, 1, curve: appEmphasizedDecelerate),
    );
  }

  @override
  void dispose() {
    _t?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    if (t == null) return widget.child;
    return Entrance(t: t, child: widget.child);
  }
}

/// A row of a data list (transactions, requests, notifications...) that
/// fades and rises in when it appears, cascading after the rows above it.
///
/// ```dart
/// for (final (i, item) in visible.indexed)
///   ListItemEntrance(id: item, group: _filter, index: i, child: Tile(item)),
/// ```
///
/// * On screen open the enclosing [EntranceScope] already brings everything
///   in, so a row built then just records itself and doesn't animate twice.
/// * After that, a row plays when it's new: a changed [group] (the active
///   filter) makes every row of the new list new, so filtering cascades in.
/// * A row that scrolls out and back keeps its `id`/`group`, so it doesn't
///   replay.
///
/// The widget is keyed by `(group, id)`, so rows that stay put across a
/// rebuild keep their state and don't restart.
///
/// Set [always] for rows of a tab pane: the pane is rebuilt on every tab
/// switch, and its rows should cascade in each time it appears, not just the
/// first.
class ListItemEntrance extends StatefulWidget {
  ListItemEntrance({
    required this.id,
    required this.index,
    required this.child,
    this.group,
    this.always = false,
    this.delay = Duration.zero,
  }) : super(key: ValueKey((group, id)));

  /// Identifies the row's data (the item itself, or its id).
  final Object id;

  /// Position among the rows appearing together; sets the cascade delay.
  final int index;

  /// What the list currently shows, such as the selected filter.
  final Object? group;

  /// Plays whenever the row is built (except during the screen's opening
  /// entrance), instead of only the first time its id is shown.
  final bool always;

  /// Extra wait before the cascade starts, e.g. [AppTabView.incomingDelay]
  /// for rows of a pane that is still fading in.
  final Duration delay;

  final Widget child;

  static const _base = Duration(milliseconds: 260);
  static const _step = Duration(milliseconds: 30);

  /// Rows past this many all start together, so long lists don't trail.
  static const _maxSteps = 6;

  @override
  State<ListItemEntrance> createState() => _ListItemEntranceState();
}

class _ListItemEntranceState extends State<ListItemEntrance>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  CurvedAnimation? _t;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null || _t != null) return;
    final scope = context
        .dependOnInheritedWidgetOfExactType<_EntranceController>();
    final id = (widget.group, widget.id);
    final firstTime = (scope?.seen.add(id) ?? true) || widget.always;
    final opening = scope != null && !scope.controller.isCompleted;
    if (!firstTime || opening || MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    final delay =
        widget.delay +
        ListItemEntrance._step *
            widget.index.clamp(0, ListItemEntrance._maxSteps);
    final total = delay + ListItemEntrance._base;
    final controller = AnimationController(vsync: this, duration: total);
    _controller = controller;
    _t = CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: appEmphasizedDecelerate,
      ),
    );
    controller.forward();
  }

  @override
  void dispose() {
    _t?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    if (t == null) return widget.child;
    return Entrance(t: t, offsetY: 12, child: widget.child);
  }
}
