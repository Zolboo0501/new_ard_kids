import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';

/// Signed-in root built by go_router's `StatefulShellRoute`: the Home and
/// Profile tabs are branches of [navigationShell] (each keeps its own state
/// and URL), and the raised QR button pushes `/qr` above the shell.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTab(int index) {
    // Tapping the active tab again returns that branch to its first screen.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FE),
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: FloatingNavBar(
        index: navigationShell.currentIndex,
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
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.cottage_rounded,
                  outlinedIcon: Icons.cottage_outlined,
                  label: 'Нүүр',
                  selected: index == 0,
                  onTap: () => onTab(0),
                ),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'QR уншуулах',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onQr,
                      // The circle rises above the bar, so lay it out in a
                      // Stack rather than a Column that must fit the height.
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: -16,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [AppColors.sky500, AppColors.sky400],
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.sky500.withValues(
                                      alpha: 0.35,
                                    ),
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
                          Positioned(
                            bottom: 6,
                            child: Text(
                              'QR',
                              style: comfortaa(
                                size: 11,
                                weight: FontWeight.w700,
                                color: AppColors.slate600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.account_circle_rounded,
                  outlinedIcon: Icons.account_circle_outlined,
                  label: 'Профайл',
                  selected: index == 1,
                  onTap: () => onTab(1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final color = selected ? AppColors.sky500 : AppColors.slate400;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? icon : outlinedIcon, size: 24, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: comfortaa(
                  size: 11,
                  weight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
