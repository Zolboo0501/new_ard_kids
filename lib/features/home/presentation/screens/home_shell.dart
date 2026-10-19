import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../widgets/floating_nav_bar.dart';

/// Signed-in root built by go_router's `StatefulShellRoute`: the Home, QR,
/// Chat and Profile tabs are branches of [navigationShell] (each keeps its
/// own state and URL). The bar's order is Нүүр · QR · Чат · Профайл.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// How fast (logical px/s) a sideways drag must end to move to the next
  /// tab.
  static const swipeVelocity = 300.0;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  /// Plays once per branch change. It starts settled so the first frame of
  /// the shell is not faded in from nothing.
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: 1,
  );
  late final CurvedAnimation _curved = CurvedAnimation(
    parent: _enter,
    curve: appEmphasizedDecelerate,
  );

  /// Set eagerly in [initState]: a `late` initialiser would not be touched
  /// until the first [didUpdateWidget], by which point the index has already
  /// changed and the switch would go unnoticed.
  late int _index;

  /// Which way the content travels: right when moving to a later tab.
  double _direction = 1;

  /// Whether the bottom bar is shrunk: set while the page scrolls down,
  /// cleared when it scrolls back up or the tab changes.
  bool _compact = false;

  /// Where the bar's disc sits while a sideways drag is under way, in tabs
  /// (0 Нүүр … 3 Профайл, fractions in between); null otherwise.
  double? _drag;

  /// The tab a released drag is heading to, until the router reports it, so
  /// the disc doesn't swing back to the old tab for a frame in between.
  int? _target;

  @override
  void initState() {
    super.initState();
    _index = widget.navigationShell.currentIndex;
  }

  @override
  void didUpdateWidget(HomeShell old) {
    super.didUpdateWidget(old);
    final next = widget.navigationShell.currentIndex;
    if (next == _index) return;
    _target = null;
    _direction = next > _index ? 1 : -1;
    _index = next;
    _compact = false;
    // The branches live in an IndexedStack, so the new one is already on
    // screen by the time we get here; there is no outgoing frame to hold.
    // Animating the arrival is what turns the cut into a transition.
    if (!MediaQuery.disableAnimationsOf(context)) _enter.forward(from: 0);
  }

  @override
  void dispose() {
    _curved.dispose();
    _enter.dispose();
    super.dispose();
  }

  bool _onScroll(UserScrollNotification n) {
    // Only the page's own vertical scrolling; the balance carousel and other
    // sideways lists leave the bar alone.
    if (n.metrics.axis != Axis.vertical) return false;
    final compact = switch (n.direction) {
      ScrollDirection.reverse => true,
      ScrollDirection.forward => false,
      ScrollDirection.idle => _compact && n.metrics.extentBefore > 0,
    };
    if (compact != _compact) setState(() => _compact = compact);
    return false;
  }

  void _onTab(int index) {
    if (index != widget.navigationShell.currentIndex) {
      HapticFeedback.selectionClick();
    }
    // Tapping the active tab again returns that branch to its first screen.
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  /// The last tab's index.
  int get _lastTab => widget.navigationShell.route.branches.length - 1;

  /// A sideways drag slides the bar's disc with the finger, Нүүр · QR ·
  /// Чат · Профайл: left towards the next tab, right towards the one before.
  /// Sideways lists inside a tab (the balance carousel, filter chips) sit
  /// deeper and win their own drags.
  void _onDragStart(DragStartDetails _) {
    setState(() => _drag = widget.navigationShell.currentIndex.toDouble());
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final drag = _drag;
    if (drag == null) return;
    final perTab = MediaQuery.sizeOf(context).width * _dragPerTab;
    setState(
      () => _drag = (drag - details.primaryDelta! / perTab).clamp(
        0,
        _lastTab.toDouble(),
      ),
    );
  }

  /// On release a fling moves one tab its way; a slow drag settles on the
  /// tab the disc is nearest.
  void _onDragEnd(DragEndDetails details) {
    final from = widget.navigationShell.currentIndex;
    final v = details.primaryVelocity ?? 0;
    final next =
        (v.abs() >= HomeShell.swipeVelocity
                ? from + (v < 0 ? 1 : -1)
                : (_drag ?? from).round())
            .clamp(0, _lastTab);
    setState(() {
      _drag = null;
      if (next != from) _target = next;
    });
    if (next != from) _onTab(next);
  }

  void _onDragCancel() => setState(() => _drag = null);

  /// How much of the screen's width a drag covers to move the disc one tab.
  static const _dragPerTab = 0.5;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onHorizontalDragCancel: _onDragCancel,
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        extendBody: true,
        body: AnimatedBuilder(
          animation: _curved,
          // The shell is passed as `child` so a running transition repaints
          // without rebuilding either branch underneath it.
          child: NotificationListener<UserScrollNotification>(
            onNotification: _onScroll,
            child: widget.navigationShell,
          ),
          builder: (context, child) {
            final t = _curved.value;
            if (t == 1) return child!;
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(28 * _direction * (1 - t), 0),
                child: child,
              ),
            );
          },
        ),
        bottomNavigationBar: FloatingNavBar(
          index: _target ?? widget.navigationShell.currentIndex,
          dragPosition: _drag,
          onTab: _onTab,
          compact: _compact,
        ),
      ),
    );
  }
}
