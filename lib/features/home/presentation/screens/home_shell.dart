import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../widgets/floating_nav_bar.dart';

/// Signed-in root built by go_router's `StatefulShellRoute`: the Home and
/// Profile tabs are branches of [navigationShell] (each keeps its own state
/// and URL), and the raised QR button pushes `/qr` above the shell.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

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
    _direction = next > _index ? 1 : -1;
    _index = next;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      extendBody: true,
      body: AnimatedBuilder(
        animation: _curved,
        // The shell is passed as `child` so a running transition repaints
        // without rebuilding either branch underneath it.
        child: widget.navigationShell,
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
        index: widget.navigationShell.currentIndex,
        onTab: _onTab,
        onQr: () => context.push(AppRoutes.qrScan),
      ),
    );
  }
}
