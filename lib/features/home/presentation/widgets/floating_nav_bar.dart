import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';

/// The floating bottom bar: a pill in the theme's accent with three round
/// buttons, Нүүр · QR · Профайл. Each button sits on a faint disc of its
/// own; a card-coloured disc carrying a small dot slides under the selected
/// tab, and its icon takes the accent ink on it.
///
/// Every colour comes from the theme tokens, so the bar follows the accent
/// picked in Харагдац. On the dark canvas it turns into a dark raised pill
/// with the accent disc under the selected tab.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.index,
    required this.onTab,
    this.dragPosition,
    this.compact = false,
  });

  final int index;
  final ValueChanged<int> onTab;

  /// Where the selected disc sits while the page is dragged sideways, in
  /// tabs (fractions between them); it follows the finger instead of
  /// animating. Null when no drag is under way.
  final double? dragPosition;

  /// Shrinks the pill while the page scrolls down, so it covers less of
  /// the content; it grows back when the page scrolls up.
  final bool compact;

  static const _duration = Duration(milliseconds: 320);

  /// A button's diameter (full and compact), and the gap around the buttons.
  static const _button = 60.0;
  static const _compactButton = 54.0;
  static const _gap = 6.0;

  /// The widest the bar gets (full and compact).
  static const _maxWidth = 236.0;
  static const _compactMaxWidth = 212.0;

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
        // Always the full bar's height, so the page's bottom padding (which
        // the Scaffold derives from it) doesn't move while the pill shrinks.
        child: SizedBox(
          height: _button + _gap * 2,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: compact ? 1 : 0),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : _duration,
            curve: appEmphasizedDecelerate,
            builder: (context, t, _) {
              final button = lerpDouble(_button, _compactButton, t)!;
              return Align(
                alignment: Alignment.bottomCenter,
                // Wide on a phone, capped so it stays a pill on a tablet.
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: lerpDouble(_maxWidth, _compactMaxWidth, t)!,
                  ),
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
                      height: button,
                      child: _buttons(button, lerpDouble(26, 23.4, t)!),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buttons(double size, double iconSize) {
    final drag = dragPosition;
    // During a drag the tab nearest the disc takes the selected look.
    final selected = drag?.round() ?? index;
    return Stack(
      children: [
        // The light disc, sliding between the three tabs.
        Positioned.fill(
          child: AnimatedAlign(
            // Under the finger while dragging; eased into place otherwise,
            // from wherever the drag left it.
            duration: drag != null ? Duration.zero : _duration,
            curve: appEmphasizedDecelerate,
            alignment: Alignment((drag ?? index.toDouble()) - 1, 0),
            child: _SelectedDisc(color: _disc, ring: _dotRing, size: size),
          ),
        ),
        // The three buttons spread across the bar; the disc's -1/0/1 land
        // on them in turn.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavButton(
              icon: LineGlyph.home,
              label: 'Нүүр',
              selected: selected == 0,
              size: size,
              iconSize: iconSize,
              onTap: () => onTab(0),
            ),
            _NavButton(
              icon: LineGlyph.scan,
              label: 'QR уншуулах',
              selected: selected == 1,
              size: size,
              iconSize: iconSize,
              onTap: () => onTab(1),
            ),
            _NavButton(
              icon: LineGlyph.profile,
              label: 'Профайл',
              selected: selected == 2,
              size: size,
              iconSize: iconSize,
              onTap: () => onTab(2),
            ),
          ],
        ),
      ],
    );
  }
}

/// The disc under the selected tab, with a dot in the theme's accent on
/// its upper-right edge, ringed so it stands apart from what it overlaps.
class _SelectedDisc extends StatelessWidget {
  const _SelectedDisc({
    required this.color,
    required this.ring,
    required this.size,
  });

  final Color color;
  final Color ring;
  final double size;

  @override
  Widget build(BuildContext context) {
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
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  final LineGlyph icon;
  final String label;
  final bool selected;
  final double size;
  final double iconSize;
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
            width: widget.size,
            height: widget.size,
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
              builder: (context, tint, _) => LineIcon(
                widget.icon,
                size: widget.iconSize,
                color: tint ?? color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
