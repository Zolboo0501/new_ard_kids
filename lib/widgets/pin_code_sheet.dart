import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'app_text.dart';
import 'numeric_keypad.dart';
import 'ui.dart';

/// Checks an entered PIN; resolves `true` when it is correct.
typedef PinVerifier = Future<bool> Function(String pin);

/// Opens a [PinCodeSheet] and resolves `true` once the PIN is verified,
/// or `null` when the kid closes it.
Future<bool?> showPinCodeSheet(
  BuildContext context, {
  required PinVerifier onVerify,
  String title = 'ПИН код оруулна уу',
  String subtitle = '4 оронтой нууц кодоо оруулна уу',
  Widget? summary,
  int length = 4,
  VoidCallback? onForgot,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => PinCodeSheet(
      onVerify: onVerify,
      title: title,
      subtitle: subtitle,
      summary: summary,
      length: length,
      onForgot: onForgot,
    ),
  );
}

/// Bottom-sheet PIN entry: dots, an optional [summary] of what is being
/// confirmed, and a [NumericKeypad]. Verifies as soon as [length] digits are
/// in; a wrong PIN shakes the dots, clears them and says how many tries are
/// left. After [maxAttempts] wrong PINs in a row the keypad locks for
/// [lockout], across every PIN sheet in the app, so closing and reopening
/// the sheet doesn't reset the count.
class PinCodeSheet extends StatefulWidget {
  const PinCodeSheet({
    super.key,
    required this.onVerify,
    this.title = 'ПИН код оруулна уу',
    this.subtitle = '4 оронтой нууц кодоо оруулна уу',
    this.summary,
    this.length = 4,
    this.onForgot,
  });

  final PinVerifier onVerify;
  final String title;
  final String subtitle;
  final Widget? summary;
  final int length;
  final VoidCallback? onForgot;

  static const maxAttempts = 3;
  static const lockout = Duration(minutes: 5);

  static int _failures = 0;
  static DateTime? _lockedUntil;

  /// Clears the wrong-PIN count and any lock. For tests.
  @visibleForTesting
  static void resetLockout() {
    _failures = 0;
    _lockedUntil = null;
  }

  static bool get _locked {
    final until = _lockedUntil;
    if (until == null) return false;
    if (DateTime.now().isBefore(until)) return true;
    _lockedUntil = null;
    _failures = 0;
    return false;
  }

  @override
  State<PinCodeSheet> createState() => _PinCodeSheetState();
}

class _PinCodeSheetState extends State<PinCodeSheet>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _error = false;
  bool _checking = false;

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Future<void> _digit(String d) async {
    if (PinCodeSheet._locked) return setState(() {});
    if (_checking || _pin.length == widget.length) return;
    setState(() {
      _error = false;
      _pin += d;
    });
    if (_pin.length < widget.length) return;

    setState(() => _checking = true);
    final ok = await widget.onVerify(_pin);
    if (!mounted) return;
    if (ok) {
      PinCodeSheet._failures = 0;
      HapticFeedback.lightImpact();
      Navigator.of(context).pop(true);
      return;
    }
    HapticFeedback.heavyImpact();
    if (++PinCodeSheet._failures >= PinCodeSheet.maxAttempts) {
      PinCodeSheet._lockedUntil = DateTime.now().add(PinCodeSheet.lockout);
    }
    if (!MediaQuery.disableAnimationsOf(context)) _shake.forward(from: 0);
    setState(() {
      _checking = false;
      _error = true;
      _pin = '';
    });
  }

  void _backspace() {
    if (_checking || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  String get _message {
    if (PinCodeSheet._locked) {
      return 'ПИН код ${PinCodeSheet.maxAttempts} удаа буруу орсон тул '
          '${PinCodeSheet.lockout.inMinutes} минут түгжигдлээ. Мартсан бол '
          'эцэг эхээсээ сэргээлгэнэ үү.';
    }
    if (!_error) return widget.subtitle;
    final left = PinCodeSheet.maxAttempts - PinCodeSheet._failures;
    return 'ПИН код буруу байна. $left оролдлого үлдлээ.';
  }

  @override
  Widget build(BuildContext context) {
    final locked = PinCodeSheet._locked;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: locked ? AppColors.rose50 : AppColors.slate50,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: LineIcon(
                LineGlyph.lock,
                size: 26,
                color: locked ? AppColors.rose500 : AppColors.slate800,
              ),
            ),
            const SizedBox(height: 14),
            AppText(widget.title, size: 18, weight: FontWeight.w700),
            const SizedBox(height: 6),
            AppText(
              _message,
              size: 13,
              color: _error || locked ? AppColors.rose500 : AppColors.slate500,
              textAlign: TextAlign.center,
              height: 1.4,
            ),
            if (widget.summary != null) ...[
              const SizedBox(height: 14),
              widget.summary!,
            ],
            const SizedBox(height: 20),
            Semantics(
              label: 'ПИН код, ${_pin.length}/${widget.length} оруулсан',
              excludeSemantics: true,
              child: SizedBox(
                height: 24,
                child: _checking
                    ? Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.sky500,
                          ),
                        ),
                      )
                    : _PinDots(
                        length: widget.length,
                        filled: _pin.length,
                        error: _error,
                        shake: _shake,
                      ),
              ),
            ),
            const SizedBox(height: 22),
            IgnorePointer(
              ignoring: locked,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: locked ? 0.35 : 1,
                child: NumericKeypad(
                  style: KeypadStyle(
                    keyHeight: 60,
                    radius: 30,
                    gap: 12,
                    fontSize: 24,
                    border: AppColors.slate100,
                  ),
                  onDigit: _digit,
                  onBackspace: _backspace,
                ),
              ),
            ),
            if (widget.onForgot != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: withHaptic(widget.onForgot),
                child: AppText(
                  'ПИН кодоо мартсан уу?',
                  size: 13,
                  weight: FontWeight.w700,
                  color: AppColors.sky600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.length,
    required this.filled,
    required this.error,
    required this.shake,
  });

  final int length;
  final int filled;
  final bool error;
  final AnimationController shake;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shake,
      builder: (context, child) {
        if (shake.isDismissed) return child!;
        final decay = 1 - shake.value;
        final dx = math.sin(shake.value * math.pi * 6) * 8 * decay;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < length; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < filled ? AppColors.sky500 : AppColors.slate100,
                border: Border.all(
                  color: error
                      ? AppColors.rose400
                      : i < filled
                      ? AppColors.sky500
                      : AppColors.slate200,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
