import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class ConfirmButton extends StatefulWidget {
  const ConfirmButton({
    super.key,
    required this.dimmed,
    required this.onPressed,
  });

  /// Fades the button back while the form is incomplete. It stays tappable so
  /// a press can explain what is missing.
  final bool dimmed;
  final VoidCallback onPressed;

  @override
  State<ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<ConfirmButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final ink = widget.dimmed ? AppColors.slate500 : AppColors.onAccent;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: withHaptic(widget.onPressed),
        // Presses in slightly, and settles back up when the username becomes
        // valid and the button enables.
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          curve: appEmphasizedDecelerate,
          // Dimmed, it drops to a raised surface with muted ink: fading the
          // accent fill on the dark canvas would read as a muddy teal.
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: appEmphasizedDecelerate,
            height: 52,
            decoration: BoxDecoration(
              color: widget.dimmed ? AppColors.slate100 : AppColors.sky500,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  'Хүсэлт илгээх',
                  size: 15,
                  weight: FontWeight.w600,
                  color: ink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
