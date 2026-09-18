import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/numeric_keypad.dart';

/// "OTP Баталгаажуулалт" screen: enter the 4-digit code sent by SMS.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});

  /// 8-digit local phone number (without +976).
  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _codeLength = 4;
  static const _resendSeconds = 60;

  String _code = '';
  int _secondsLeft = _resendSeconds;
  Timer? _timer;
  bool _completePulse = false;

  bool get _complete => _code.length == _codeLength;

  static String _formatSeconds(int total) {
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _formattedPhone {
    final p = widget.phone;
    if (p.length != 8) return '+976 $p';
    return '+976 ${p.substring(0, 4)} ${p.substring(4)}';
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) t.cancel();
      setState(() => _secondsLeft--);
    });
  }

  void _resend() {
    // TODO: call the resend-OTP API.
    setState(() => _code = '');
    _startCountdown();
  }

  void _onDigit(String d) {
    if (_complete) return;
    setState(() => _code += d);
    if (_complete) {
      setState(() => _completePulse = true);
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _completePulse = false);
      });
    }
  }

  void _onBackspace() {
    if (_code.isEmpty) return;
    setState(() => _code = _code.substring(0, _code.length - 1));
  }

  void _verify() {
    if (!_complete) return;
    // TODO: verify the code with the API before continuing.
    context.push(AppRoutes.friendCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dsSurface,
      body: SafeArea(
        // The keypad is pinned to the bottom and never scrolls; only the
        // content above it scrolls, so the keys stay reachable on short
        // screens.
        child: Column(
          children: [
            const _Header(step: 'Алхам 2/3'),
            Expanded(
              // Give the scrolling child a minimum height of the viewport so
              // the content can be centred in the space left above the
              // keypad; it still scrolls when it grows past that.
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const padding = EdgeInsets.fromLTRB(16, 8, 16, 16);
                  return SingleChildScrollView(
                    padding: padding,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight - padding.vertical)
                            .clamp(0.0, double.infinity),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 448),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeroRow(),
                              const SizedBox(height: 16),
                              _buildCodeCard(),
                              const SizedBox(height: 16),
                              AnimatedScale(
                                scale: _completePulse ? 1.05 : 1,
                                duration: const Duration(milliseconds: 150),
                                child: _VerifyButton(
                                  enabled: _complete,
                                  onPressed: _verify,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  /// Title and instructions on the left, mascot on the right.
  Widget _buildHeroRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Код баталгаажуулах',
                style: comfortaa(
                  size: 22,
                  weight: FontWeight.w700,
                  color: AppColors.dsOnSurface,
                  height: 1.3,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              _buildInstructions(),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const _PandaHero(size: 128),
      ],
    );
  }

  /// The digit pad, pinned below the scrolling content.
  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.dsSurfaceContainerLow.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(40),
            ),
            child: NumericKeypad(
              style: const KeypadStyle(
                keyHeight: 56,
                radius: 32,
                gap: 4,
                fontSize: 18,
                textColor: AppColors.dsOnSurface,
                pressedColor: AppColors.dsSurfaceContainerHigh,
              ),
              onDigit: _onDigit,
              onBackspace: _onBackspace,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    final base = comfortaa(
      size: 14,
      weight: FontWeight.w500,
      color: AppColors.dsOnSurfaceVariant,
      height: 1.625,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(
            text: _formattedPhone,
            style: base.copyWith(
              fontWeight: FontWeight.w700,
              fontVariations: const [FontVariation.weight(700)],
              color: AppColors.dsOnSurface,
            ),
          ),
          const TextSpan(
            text: ' дугаарт ирсэн 4 оронтой нууц кодыг оруулна уу. ',
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Text(
                'Өөрчлөх',
                style: base.copyWith(
                  fontWeight: FontWeight.w700,
                  fontVariations: const [FontVariation.weight(700)],
                  color: AppColors.dsPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.start,
    );
  }

  Widget _buildCodeCard() {
    final counting = _secondsLeft > 0;
    final label = comfortaa(
      size: 12,
      weight: FontWeight.w500,
      color: AppColors.dsOnSurfaceVariant,
      letterSpacing: 0.24,
    );
    final accent = comfortaa(
      size: 12,
      weight: FontWeight.w700,
      color: AppColors.dsPrimary,
      letterSpacing: 0.24,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _codeLength; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _OtpBox(
                  digit: i < _code.length ? _code[i] : null,
                  active: i == _code.length,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 18,
                color: AppColors.dsPrimary,
              ),
              const SizedBox(width: 4),
              Text('Дахин код авах:', style: label),
              const SizedBox(width: 4),
              if (counting)
                Text(
                  _formatSeconds(_secondsLeft),
                  style: accent.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                )
              else ...[
                Text(
                  '•',
                  style: label.copyWith(color: AppColors.dsOutlineVariant),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _resend,
                  child: Text('Дахин илгээх', style: accent),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.step});

  final String step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: CircleBackButton(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.sky50,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.sky100.withValues(alpha: 0.8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _PulsingDot(),
                const SizedBox(width: 6),
                Text(
                  step,
                  style: comfortaa(
                    size: 12,
                    weight: FontWeight.w700,
                    color: AppColors.sky600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.5).animate(_controller),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.sky500,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _PandaHero extends StatelessWidget {
  const _PandaHero({this.size = 176});

  /// Side of the square the mascot is laid out in. The glow and the image
  /// keep the proportions of the original 176px hero.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft sky glow standing in for the CSS drop-shadow filter.
          Container(
            width: size * 0.682,
            height: size * 0.682,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.sky500.withValues(alpha: 0.15),
                  offset: const Offset(0, 8),
                  blurRadius: 32,
                ),
              ],
            ),
          ),
          MascotImage(
            asset: 'assets/images/mascot_panda_key.png',
            size: size * 0.909,
            background: AppColors.dsSurface,
            semanticLabel: 'Алтан түлхүүр барьсан панда',
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.digit, required this.active});

  final String? digit;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 56,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: digit != null ? AppColors.dsSurfaceContainerLow : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: active
              ? AppColors.sky500.withValues(alpha: 0.4)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: digit != null
          ? Text(
              digit!,
              style: comfortaa(
                size: 22,
                weight: FontWeight.w700,
                color: AppColors.dsPrimary,
              ),
            )
          : active
          ? const BlinkingCursor(color: AppColors.dsPrimary)
          : null,
    );
  }
}

class _VerifyButton extends StatelessWidget {
  const _VerifyButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.6,
          duration: const Duration(milliseconds: 200),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.dsPrimaryContainer,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Баталгаажуулах',
                  style: comfortaa(
                    size: 14,
                    weight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.14,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
