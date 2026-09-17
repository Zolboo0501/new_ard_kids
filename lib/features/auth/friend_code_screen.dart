import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/numeric_keypad.dart';

/// "Найзын код оруулах" screen: optional 6-digit referral code.
class FriendCodeScreen extends StatefulWidget {
  const FriendCodeScreen({super.key});

  @override
  State<FriendCodeScreen> createState() => _FriendCodeScreenState();
}

class _FriendCodeScreenState extends State<FriendCodeScreen> {
  static const _codeLength = 6;

  String _code = '';

  bool get _complete => _code.length == _codeLength;

  void _onDigit(String d) {
    if (_complete) return;
    setState(() => _code += d);
  }

  void _onBackspace() {
    if (_code.isEmpty) return;
    setState(() => _code = _code.substring(0, _code.length - 1));
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final digits = (data?.text ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty || !mounted) return;
    setState(
      () => _code = digits.substring(0, digits.length.clamp(0, _codeLength)),
    );
  }

  void _finish({required bool skipped}) {
    // TODO: submit the referral code before continuing.
    if (!skipped) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Урилгын код: $_code',
              style: comfortaa(size: 13, color: Colors.white),
            ),
          ),
        );
    }
    context.push(AppRoutes.avatarPicker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: Stack(
        children: [
          const _AmbientGlow(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 448),
                        child: _buildContent(),
                      ),
                    ),
                  ),
                ),
                _buildKeypad(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CircleBackButton(),
              _SkipButton(onPressed: () => _finish(skipped: true)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const SizedBox(
          width: 128,
          height: 128,
          child: Center(
            child: MascotImage(
              asset: 'assets/images/mascot_fox.jpg',
              size: 112,
              background: AppColors.slate50,
              semanticLabel: 'Үнэг маскот',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Найзын урилгын код',
          textAlign: TextAlign.center,
          style: comfortaa(
            size: 24,
            weight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            'Найзаасаа авсан 6 оронтой урилгын кодыг оруулж, хоёулаа урамшуулал аваарай!',
            textAlign: TextAlign.center,
            style: comfortaa(
              size: 13,
              weight: FontWeight.w500,
              color: AppColors.slate500,
              height: 1.625,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildCodeCard(),
        const SizedBox(height: 10),
        const _RewardBanner(),
        const SizedBox(height: 12),
        _ConfirmButton(
          enabled: _complete,
          onPressed: () => _finish(skipped: false),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCodeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _codeLength; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Flexible(
                  child: _CodeBox(
                    digit: i < _code.length ? _code[i] : null,
                    active: i == _code.length,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Код хараахан аваагүй юу?',
              style: comfortaa(
                size: 12,
                weight: FontWeight.w500,
                color: AppColors.slate400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(BuildContext context) {
    const style = KeypadStyle(
      keyHeight: 52,
      radius: 16,
      gap: 10,
      fontSize: 20,
      border: AppColors.slate100,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.slate100.withValues(alpha: 0.7),
        border: Border(
          top: BorderSide(color: AppColors.slate200.withValues(alpha: 0.6)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 384),
          child: NumericKeypad(
            style: style,
            onDigit: _onDigit,
            onBackspace: _onBackspace,
            bottomLeft: KeypadKey(
              style: const KeypadStyle(
                keyHeight: 52,
                radius: 16,
                gap: 10,
                fontSize: 20,
                border: AppColors.slate200,
              ),
              background: Colors.white.withValues(alpha: 0.6),
              onTap: _paste,
              semanticLabel: 'Хуулсан код оруулах',
              child: const Icon(
                Icons.content_paste_go_rounded,
                size: 20,
                color: AppColors.slate500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow();

  @override
  Widget build(BuildContext context) {
    Widget blob(double size, Color color) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -96,
            left: -80,
            child: blob(360, AppColors.sky200.withValues(alpha: 0.45)),
          ),
          Positioned(
            top: 40,
            right: -80,
            child: blob(320, AppColors.indigo100.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.slate100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Алгасах',
              style: comfortaa(
                size: 11.5,
                weight: FontWeight.w700,
                color: AppColors.slate500,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColors.slate500,
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({required this.digit, required this.active});

  final String? digit;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final filled = digit != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 44,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled
            ? AppColors.sky50.withValues(alpha: 0.8)
            : active
            ? Colors.white
            : AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: filled
              ? AppColors.sky100
              : active
              ? AppColors.sky500
              : AppColors.slate200.withValues(alpha: 0.7),
          width: active ? 2 : 1,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.sky100,
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ]
            : null,
      ),
      child: filled
          ? Text(
              digit!,
              style: comfortaa(
                size: 24,
                weight: FontWeight.w700,
                color: AppColors.sky700,
              ),
            )
          : active
          ? const BlinkingCursor(height: 22)
          : Text(
              '•',
              style: comfortaa(
                size: 20,
                weight: FontWeight.w500,
                color: AppColors.slate300,
              ),
            ),
    );
  }
}

class _RewardBanner extends StatelessWidget {
  const _RewardBanner();

  @override
  Widget build(BuildContext context) {
    final base = comfortaa(
      size: 11.5,
      weight: FontWeight.w600,
      color: AppColors.emerald800,
      height: 1.25,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.emerald50.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.emerald200.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.emerald100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              size: 16,
              color: AppColors.emerald600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: base,
                children: [
                  const TextSpan(
                    text: 'Код оруулснаар та болон таны найз тус бүр ',
                  ),
                  TextSpan(
                    text: '+₮10,000',
                    style: base.copyWith(
                      color: AppColors.emerald950,
                      fontWeight: FontWeight.w700,
                      fontVariations: const [FontVariation.weight(700)],
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.emerald400,
                    ),
                  ),
                  const TextSpan(text: ' бэлэг авна!'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.enabled, required this.onPressed});

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
              gradient: const LinearGradient(
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
                Text(
                  'Баталгаажуулах',
                  style: comfortaa(
                    size: 16,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
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
    );
  }
}
