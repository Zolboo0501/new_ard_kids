import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text.dart';
import '../../widgets/value_switcher.dart';

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

/// Rounded floating bottom bar: Нүүр · QR · Профайл.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.index,
    required this.onTab,
    required this.onQr,
  });

  final int index;
  final ValueChanged<int> onTab;
  final VoidCallback onQr;

  static const _duration = Duration(milliseconds: 320);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 12 + bottom),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.slate100),
              boxShadow: [
                BoxShadow(
                  color: AppColors.slate900.withValues(alpha: 0.10),
                  offset: const Offset(0, 10),
                  blurRadius: 24,
                ),
              ],
            ),
            // Clip.none so the raised QR circle can still overflow the bar.
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // A tinted pill that travels behind the selected tab. It only
                // ever sits over the outer thirds, never behind the QR button.
                Positioned.fill(
                  child: AnimatedAlign(
                    duration: _duration,
                    curve: appEmphasizedDecelerate,
                    alignment: Alignment(index == 0 ? -1 : 1, 0),
                    child: FractionallySizedBox(
                      widthFactor: 1 / 3,
                      heightFactor: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.sky50,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _NavItem(
                      icon: Icons.cottage_rounded,
                      outlinedIcon: Icons.cottage_outlined,
                      label: 'Нүүр',
                      selected: index == 0,
                      onTap: () => onTab(0),
                    ),
                    Expanded(child: _QrButton(onTap: onQr)),
                    _NavItem(
                      icon: Icons.account_circle_rounded,
                      outlinedIcon: Icons.account_circle_outlined,
                      label: 'Профайл',
                      selected: index == 1,
                      onTap: () => onTab(1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The raised circle in the middle of the bar.
class _QrButton extends StatefulWidget {
  const _QrButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_QrButton> createState() => _QrButtonState();
}

class _QrButtonState extends State<_QrButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'QR уншуулах',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        // The circle rises above the bar, so lay it out in a Stack rather
        // than a Column that must fit the height.
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -16,
              child: AnimatedScale(
                scale: _pressed ? 0.92 : 1,
                duration: const Duration(milliseconds: 140),
                curve: appEmphasizedDecelerate,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [AppColors.sky500, AppColors.sky400],
                    ),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sky500.withValues(alpha: 0.35),
                        offset: const Offset(0, 6),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: 6,
              child: AppText(
                'QR',
                size: 11,
                weight: FontWeight.w700,
                color: AppColors.slate600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  static const _duration = Duration(milliseconds: 320);

  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final color = selected ? AppColors.sky500 : AppColors.slate400;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? 0.92 : 1,
            duration: const Duration(milliseconds: 140),
            curve: appEmphasizedDecelerate,
            child: TweenAnimationBuilder<Color?>(
              duration: _duration,
              curve: appEmphasizedDecelerate,
              tween: ColorTween(end: color),
              builder: (context, tint, _) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The filled and outlined glyphs are different icons, so
                  // cross-fade them rather than swapping in place.
                  ValueSwitcher(
                    value: selected,
                    duration: _duration,
                    switchInCurve: appEmphasizedDecelerate,
                    transitionBuilder: (child, animation, _) => ScaleTransition(
                      scale: Tween(begin: 0.8, end: 1.0).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Icon(
                      selected ? widget.icon : widget.outlinedIcon,
                      key: ValueKey(selected),
                      size: 24,
                      color: tint,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: _duration,
                    curve: appEmphasizedDecelerate,
                    style: inter(
                      size: 11,
                      weight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: tint ?? color,
                    ),
                    child: Text(widget.label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
