import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';

/// The floating bottom bar, a dark pill: Нүүр · QR · Профайл. A compact
/// mint pill slides under the selected tab, and the QR button is a white
/// disc raised out of the bar's top edge, cut out from it by a dark ring.
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

  /// How far the QR disc rises above the bar's top edge.
  static const _qrLift = 14.0;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      // Room above the bar for the raised QR disc.
      padding: EdgeInsets.fromLTRB(20, _qrLift, 20, 12 + bottom),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              // Lit faintly from above so the pill reads as a raised
              // object on the black canvas, not a flat band.
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1C1E23), Color(0xFF131518)],
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Night.line),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x80000000),
                  offset: Offset(0, 12),
                  blurRadius: 28,
                ),
              ],
            ),
            // Clip.none so the raised QR circle can still overflow the bar.
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // A mint pill that travels behind the selected tab. It hugs
                // the icon and label rather than filling its third, and only
                // ever sits over the outer thirds, never behind QR.
                Positioned.fill(
                  child: AnimatedAlign(
                    duration: _duration,
                    curve: appEmphasizedDecelerate,
                    alignment: Alignment(index == 0 ? -1 : 1, 0),
                    child: FractionallySizedBox(
                      widthFactor: 1 / 3,
                      heightFactor: 1,
                      child: Center(
                        child: Container(
                          width: 82,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.sky500,
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
                      icon: LineGlyph.home,
                      label: 'Нүүр',
                      selected: index == 0,
                      onTap: () => onTab(0),
                    ),
                    Expanded(
                      child: _QrButton(onTap: onQr, lift: _qrLift),
                    ),
                    _NavItem(
                      icon: LineGlyph.profile,
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

/// The white QR disc in the middle of the bar, raised above its top edge.
/// A ring in the canvas colour cuts it out from the bar.
class _QrButton extends StatefulWidget {
  const _QrButton({required this.onTap, required this.lift});

  final VoidCallback onTap;

  /// How far the disc's centre sits above the bar's centre.
  final double lift;

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
        child: Center(
          child: Transform.translate(
            offset: Offset(0, -widget.lift),
            child: AnimatedScale(
              scale: _pressed ? 0.9 : 1,
              duration: const Duration(milliseconds: 140),
              curve: appEmphasizedDecelerate,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Night.bg, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x59000000),
                      offset: Offset(0, 6),
                      blurRadius: 16,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const LineIcon(
                  LineGlyph.scan,
                  color: Night.bg,
                  size: 24,
                  stroke: 1.7,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final LineGlyph icon;
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
    final color = selected ? AppColors.onAccent : Night.text2;

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
                  // One line glyph whose colour follows the pill: dark on
                  // the cyan block, grey off it. No halo, the pill is lit.
                  LineIcon(widget.icon, size: 24, color: tint ?? color),
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
