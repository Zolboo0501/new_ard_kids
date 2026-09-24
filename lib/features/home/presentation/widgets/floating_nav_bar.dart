import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/value_switcher.dart';

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
