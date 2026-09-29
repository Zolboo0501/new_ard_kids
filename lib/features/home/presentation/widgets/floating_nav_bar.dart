import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';

/// The floating bottom bar, a card-coloured pill: Нүүр · QR · Профайл. A
/// compact accent-tinted pill slides under the selected tab, and the QR
/// button is an accent disc raised out of the bar's top edge, cut out from
/// it by a ring in the canvas colour.
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
              color: AppColors.card,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.line),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                ),
              ],
            ),
            // Clip.none so the raised QR circle can still overflow the bar.
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // An accent-tinted pill that travels behind the selected tab. It hugs
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
                          width: 84,
                          height: 52,
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

/// The accent QR disc in the middle of the bar, raised above its top edge.
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
                  color: AppColors.sky500,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      offset: const Offset(0, 6),
                      blurRadius: 16,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: LineIcon(
                  LineGlyph.scan,
                  color: AppColors.onAccent,
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
    final color = selected ? AppColors.sky700 : AppColors.slate500;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: widget.label,
        excludeSemantics: true,
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
                  // One line glyph whose colour follows the pill: accent ink
                  // on the tinted pill, grey off it.
                  LineIcon(widget.icon, size: 24, color: tint ?? color),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: _duration,
                    curve: appEmphasizedDecelerate,
                    style: inter(
                      size: 12,
                      weight: selected ? FontWeight.w600 : FontWeight.w500,
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
