import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/app_text.dart';

/// Visual style of a [NumericKeypad] key; the Stitch screens each use a
/// slightly different key shape.
class KeypadStyle {
  const KeypadStyle({
    required this.keyHeight,
    required this.radius,
    required this.gap,
    required this.fontSize,
    this.border,
    this.textColor = AppColors.slate800,
    this.pressedColor = AppColors.slate100,
  });

  final double keyHeight;
  final double radius;
  final double gap;
  final double fontSize;
  final Color? border;
  final Color textColor;
  final Color pressedColor;
}

/// 3×4 on-screen digit keypad: 1–9, then [bottomLeft], 0, backspace.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.style,
    required this.onDigit,
    required this.onBackspace,
    this.bottomLeft,
  });

  final KeypadStyle style;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  /// Optional action key in the bottom-left slot; left empty when null.
  final KeypadKey? bottomLeft;

  @override
  Widget build(BuildContext context) {
    Widget digit(String d) => KeypadKey(
      style: style,
      onTap: () => onDigit(d),
      semanticLabel: d,
      child: AppText(
        d,
        size: style.fontSize,
        weight: FontWeight.w700,
        color: style.textColor,
      ),
    );

    final rows = [
      [digit('1'), digit('2'), digit('3')],
      [digit('4'), digit('5'), digit('6')],
      [digit('7'), digit('8'), digit('9')],
      [
        bottomLeft ?? SizedBox(height: style.keyHeight),
        digit('0'),
        KeypadKey(
          style: style,
          onTap: onBackspace,
          semanticLabel: 'Устгах',
          child: const Icon(
            Icons.backspace_outlined,
            size: 22,
            color: AppColors.slate700,
          ),
        ),
      ],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) SizedBox(height: style.gap),
          Row(
            children: [
              for (var c = 0; c < 3; c++) ...[
                if (c > 0) SizedBox(width: style.gap),
                Expanded(child: rows[r][c]),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class KeypadKey extends StatefulWidget {
  const KeypadKey({
    super.key,
    required this.style,
    required this.onTap,
    required this.child,
    required this.semanticLabel,
    this.background = Colors.white,
  });

  final KeypadStyle style;
  final VoidCallback onTap;
  final Widget child;
  final String semanticLabel;
  final Color background;

  @override
  State<KeypadKey> createState() => _KeypadKeyState();
}

class _KeypadKeyState extends State<KeypadKey> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 90),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            height: style.keyHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _pressed ? style.pressedColor : widget.background,
              borderRadius: BorderRadius.circular(style.radius),
              border: style.border == null
                  ? null
                  : Border.all(color: style.border!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
