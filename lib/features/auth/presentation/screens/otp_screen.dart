import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/numeric_keypad.dart';
import '../../../../widgets/ui.dart';
import '../widgets/header.dart';
import '../widgets/otp_box.dart';
import '../widgets/verify_button.dart';

/// "OTP Баталгаажуулалт" screen: enter the 4-digit code sent by SMS.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});

  /// 8-digit local phone number (without +976).
  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  static const _codeLength = 4;
  static const _resendSeconds = 60;

  String _code = '';
  int _secondsLeft = _resendSeconds;
  Timer? _timer;
  bool _completePulse = false;

  /// Drives the one-shot entrance: each element fades and rises over its own
  /// slice of this controller (see [Entrance]).
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  late final EntranceStagger _stagger = EntranceStagger(_entrance);
  late final Animation<double> _heroIn;
  late final Animation<double> _cardIn;
  late final Animation<double> _buttonIn;
  late final Animation<double> _keypadIn;

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
    _heroIn = _stagger.slice(0);
    _cardIn = _stagger.slice(0.12);
    _buttonIn = _stagger.slice(0.2);
    _keypadIn = _stagger.slice(0.26);
    _entrance.forward();
    _startCountdown();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced motion: show the finished layout instead of animating it in.
    if (MediaQuery.disableAnimationsOf(context)) _entrance.value = 1;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stagger.dispose();
    _entrance.dispose();
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
      backgroundColor: AppColors.surface,
      body: SafeArea(
        // The keypad is pinned to the bottom and never scrolls; only the
        // content above it scrolls, so the keys stay reachable on short
        // screens.
        child: Column(
          children: [
            const Header(step: 'Алхам 2/6'),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: AppLayout.centered(
                    const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    constraints.maxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Entrance(t: _heroIn, child: _buildIntro()),
                      const SizedBox(height: 24),
                      Entrance(
                        t: _cardIn,
                        offsetY: 22,
                        child: _buildCodeCard(),
                      ),
                      const SizedBox(height: 16),
                      Entrance(
                        t: _buttonIn,
                        offsetY: 22,
                        child: AnimatedScale(
                          scale: _completePulse ? 1.02 : 1,
                          duration: const Duration(milliseconds: 150),
                          child: VerifyButton(
                            enabled: _complete,
                            onPressed: _verify,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Entrance(t: _keypadIn, offsetY: 28, child: _buildKeypad()),
          ],
        ),
      ),
    );
  }

  /// Title, where the code went, and a way back to fix the number.
  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Код баталгаажуулах',
          size: 28,
          weight: FontWeight.w700,
          color: AppColors.slate900,
          height: 1.2,
          letterSpacing: -0.6,
        ),
        const SizedBox(height: 8),
        AppText(
          '4 оронтой кодыг дараах дугаар руу илгээлээ.',
          size: 15,
          color: AppColors.slate500,
          height: 1.45,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              _formattedPhone,
              style: moneyStyle(
                size: 15,
                weight: FontWeight.w600,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(width: 4),
            TextButton(
              onPressed: withHaptic(() => Navigator.of(context).maybePop()),
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: AppText(
                'Өөрчлөх',
                size: 15,
                weight: FontWeight.w600,
                color: AppColors.sky600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// The digit pad, pinned below the scrolling content.
  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Center(
        child: ConstrainedBox(
          // Full width on iPad, like every other screen.
          constraints: const BoxConstraints(maxWidth: AppLayout.contentMax),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: NumericKeypad(
              style: KeypadStyle(
                keyHeight: 56,
                radius: 12,
                gap: 4,
                fontSize: 20,
                textColor: AppColors.slate900,
                pressedColor: AppColors.slate50,
              ),
              onDigit: _onDigit,
              onBackspace: _onBackspace,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeCard() {
    final counting = _secondsLeft > 0;
    final label = inter(size: 13, color: AppColors.slate500);
    final accent = inter(
      size: 13,
      weight: FontWeight.w600,
      color: AppColors.sky600,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _codeLength; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                OtpBox(
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
              LineIcon(LineGlyph.clock, size: 16, color: AppColors.slate500),
              const SizedBox(width: 6),
              Text('Дахин код авах:', style: label),
              const SizedBox(width: 4),
              if (counting)
                SizedBox(
                  height: 44,
                  child: Center(
                    child: Text(
                      _formatSeconds(_secondsLeft),
                      style: accent.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: withHaptic(_resend),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: Text('Дахин илгээх', style: accent),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
