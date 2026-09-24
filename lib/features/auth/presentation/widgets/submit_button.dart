import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';
import '../../../../widgets/value_switcher.dart';

class SubmitButton extends StatefulWidget {
  const SubmitButton({
    super.key,
    required this.state,
    required this.label,
    required this.onPressed,
  });

  final SubmitState state;
  final String label;
  final VoidCallback onPressed;

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final busy = widget.state != SubmitState.idle;
    final textStyle = inter(
      size: 14,
      weight: FontWeight.w700,
      color: Colors.white,
    );

    final Widget content = switch (widget.state) {
      SubmitState.idle => Row(
        // Keyed by the label too, so switching mode cross-fades the caption
        // rather than swapping it in place.
        key: ValueKey('idle-${widget.label}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.label, style: textStyle),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_rounded,
            size: 20,
            color: Colors.white,
          ),
        ],
      ),
      SubmitState.sending => Row(
        key: const ValueKey('sending'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text('Илгээж байна...', style: textStyle),
        ],
      ),
      SubmitState.sent => Row(
        key: const ValueKey('sent'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Text('Код илгээгдлээ!', style: textStyle),
        ],
      ),
    };

    return GestureDetector(
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
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [AppColors.sky500, AppColors.sky600],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sky500.withValues(alpha: 0.3),
                  offset: const Offset(0, 8),
                  blurRadius: 18,
                  spreadRadius: -2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: ValueSwitcher(
              value: busy ? widget.state : widget.label,
              duration: const Duration(milliseconds: 180),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

enum SubmitState { idle, sending, sent }
