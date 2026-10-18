import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';

/// The floating bottom bar: a pill in the theme's accent with three round
/// buttons, Нүүр · QR · Профайл. Each button sits on a faint disc of its
/// own; a card-coloured disc carrying a small dot slides under the selected
/// tab, and its icon takes the accent ink on it. QR is an action, not a
/// tab, so the disc never rests on it.
///
/// Every colour comes from the theme tokens, so the bar follows the accent
/// picked in Харагдац. On the dark canvas it turns into a dark raised pill
/// with the accent disc under the selected tab.
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

  /// A button's diameter, and the gap around the buttons.
  static const _button = 60.0;
  static const _gap = 6.0;

  /// The widest the bar gets.
  static const _maxWidth = 236.0;

  // Light canvas: a pill in the accent with a card-coloured disc under the
  // selected tab. Dark canvas: a dark raised pill with the accent disc
  // under the selected tab, so the bar sits quietly on the night canvas
  // and only the selection glows.
  static bool get _dark => AppColors.isDark;

  /// The pill.
  static Color get _bar => _dark ? AppColors.slate50 : AppColors.sky500;

  /// The selected disc.
  static Color get _disc => _dark ? AppColors.sky500 : AppColors.card;

  /// The icons and faint discs on the pill.
  static Color get _onBar => _dark ? AppColors.slate600 : AppColors.onAccent;

  /// The icon on the selected disc.
  static Color get _selectedIcon =>
      _dark ? AppColors.onAccent : AppColors.sky600;

  /// The small dot on the selected disc: always the theme's accent.
  static Color get _dot => AppColors.sky500;

  /// The ring around the dot, which separates it from what it overlaps:
  /// the card-coloured disc and the accent pill on the light canvas, the
  /// accent disc on the dark one.
  static Color get _dotRing => _dark ? _bar : AppColors.card;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    // The bar keeps its line icons at every age (no companion stickers).
    return PlainLineIcons(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + bottom),
        child: Center(
          heightFactor: 1,
          // Wide on a phone, capped so it stays a pill on a tablet.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Container(
              padding: const EdgeInsets.all(_gap),
              decoration: BoxDecoration(
                color: _bar,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    offset: const Offset(0, 10),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: _button,
                child: Stack(
                  children: [
                    // The light disc, sliding between Нүүр and Профайл.
                    Positioned.fill(
                      child: AnimatedAlign(
                        duration: _duration,
                        curve: appEmphasizedDecelerate,
                        alignment: Alignment(index == 0 ? -1 : 1, 0),
                        child: _SelectedDisc(color: _disc, ring: _dotRing),
                      ),
                    ),
                    // The three buttons spread across the bar; the disc's -1/1
                    // ends land on the outer two.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _NavButton(
                          icon: LineGlyph.home,
                          label: 'Нүүр',
                          selected: index == 0,
                          onTap: () => onTab(0),
                        ),
                        _NavButton(
                          icon: LineGlyph.scan,
                          label: 'QR уншуулах',
                          selected: false,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onQr();
                          },
                        ),
                        _NavButton(
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
        ),
      ),
    );
  }
}

/// The disc under the selected tab, with a dot in the theme's accent on
/// its upper-right edge, ringed so it stands apart from what it overlaps.
class _SelectedDisc extends StatelessWidget {
  const _SelectedDisc({required this.color, required this.ring});

  final Color color;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    const size = FloatingNavBar._button;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: FloatingNavBar._dot,
                shape: BoxShape.circle,
                border: Border.all(color: ring, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One round button: a faint disc with an icon in the accent's text colour,
/// the icon taking the accent ink when the selected disc slides under it.
class _NavButton extends StatefulWidget {
  const _NavButton({
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
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final onBar = FloatingNavBar._onBar;
    final color = selected
        ? FloatingNavBar._selectedIcon
        : onBar.withValues(alpha: 0.9);
    return Semantics(
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
          scale: _pressed ? 0.9 : 1,
          duration: const Duration(milliseconds: 140),
          curve: appEmphasizedDecelerate,
          child: Container(
            width: FloatingNavBar._button,
            height: FloatingNavBar._button,
            decoration: BoxDecoration(
              // The faint disc; the light one slides in under the selected
              // tab instead.
              color: onBar.withValues(alpha: selected ? 0 : 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: TweenAnimationBuilder<Color?>(
              duration: FloatingNavBar._duration,
              curve: appEmphasizedDecelerate,
              tween: ColorTween(end: color),
              builder: (context, tint, _) =>
                  LineIcon(widget.icon, size: 26, color: tint ?? color),
            ),
          ),
        ),
      ),
    );
  }
}
