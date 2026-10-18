import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';
import '../../../../widgets/value_switcher.dart';

class SubmitButton extends StatefulWidget {
  const SubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.state = SubmitState.idle,
    this.dimmed = false,
  });

  final SubmitState state;
  final String label;
  final VoidCallback onPressed;

  /// Drawn muted until the step's input is complete. Still tappable: a tap
  /// is how the kid finds out what is missing.
  final bool dimmed;

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final busy = widget.state != SubmitState.idle;
    final dimmed = widget.dimmed && !busy;
    final textStyle = inter(
      size: 16,
      weight: FontWeight.w700,
      color: dimmed ? AppColors.slate400 : AppColors.onAccent,
    );

    final Widget content = switch (widget.state) {
      SubmitState.idle => Row(
        // Keyed by the label too, so switching mode cross-fades the caption
        // rather than swapping it in place.
        key: ValueKey('idle-${widget.label}'),
        mainAxisSize: MainAxisSize.min,
        children: [Text(widget.label, style: textStyle)],
      ),
      SubmitState.sending => Row(
        key: const ValueKey('sending'),
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.onAccent,
            ),
          ),
          const SizedBox(width: 8),
          Text('Илгээж байна…', style: textStyle),
        ],
      ),
      SubmitState.sent => Row(
        key: const ValueKey('sent'),
        mainAxisSize: MainAxisSize.min,
        children: [
          LineIcon(LineGlyph.check, size: 20, color: AppColors.onAccent),
          const SizedBox(width: 8),
          Text('Код илгээгдлээ', style: textStyle),
        ],
      ),
    };

    return Semantics(
      button: true,
      enabled: !busy,
      child: GestureDetector(
        onTapDown: busy ? null : (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: busy ? null : (_) => setState(() => _pressed = false),
        onTap: withHaptic(busy ? null : widget.onPressed),
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          child: AnimatedOpacity(
            opacity: busy ? 0.8 : 1,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: appEmphasizedDecelerate,
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                // A raised neutral while dimmed; a faded accent reads as a
                // muddy tint on the dark canvas.
                color: dimmed ? AppColors.slate100 : AppColors.sky500,
                // A glow in the accent's own hue lifts the one action off
                // the form; flat on the dark canvas.
                boxShadow: AppColors.isDark || dimmed
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.sky500.withValues(alpha: 0.32),
                          blurRadius: 22,
                          spreadRadius: -6,
                          offset: const Offset(0, 10),
                        ),
                      ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ValueSwitcher(
                    value: busy ? widget.state : widget.label,
                    duration: const Duration(milliseconds: 180),
                    child: content,
                  ),
                  // The round arrow, as on the welcome slides, until the
                  // button is busy.
                  Positioned(
                    right: 6,
                    child: AnimatedOpacity(
                      opacity: busy || dimmed ? 0 : 1,
                      duration: const Duration(milliseconds: 180),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.onAccent.withValues(alpha: 0.18),
                        ),
                        alignment: Alignment.center,
                        child: LineIcon(
                          LineGlyph.arrowRight,
                          size: 20,
                          color: AppColors.onAccent,
                        ),
                      ),
                    ),
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

enum SubmitState { idle, sending, sent }
