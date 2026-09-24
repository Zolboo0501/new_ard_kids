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
          child: AnimatedOpacity(
            opacity: widget.dimmed ? 0.6 : 1,
            duration: const Duration(milliseconds: 200),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.sky400, AppColors.sky500],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sky500.withValues(alpha: 0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 6,
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppText(
                    'Хүсэлт илгээх',
                    size: 16,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
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
