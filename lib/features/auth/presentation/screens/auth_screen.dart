import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_input.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';

enum AuthMode { login, register }

enum _SubmitState { idle, sending, sent }

/// "Нэвтрэх & Бүртгүүлэх" screen from the Stitch project.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  static const _phoneLength = 8;
  static const _nameMinLength = 2;
  static const _nameMaxLength = 20;

  /// Cyrillic (incl. Өө/Үү/Ёё) and Latin letters, digits and `_`. Keeps out
  /// spaces, punctuation and emoji, so the name stays a usable login handle.
  static final _nameAllowed = RegExp(r'[A-Za-zА-Яа-яЁёӨөҮү0-9_]');
  static final _nameStartsWithLetter = RegExp(r'^[A-Za-zА-Яа-яЁёӨөҮү]');

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  /// Drives the one-shot entrance: each element fades and rises over its own
  /// slice of this controller (see [Entrance]).
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );

  /// One curved slice per element, built once in [initState].
  late final EntranceStagger _stagger = EntranceStagger(_entrance);
  late final Animation<double> _mascotIn;
  late final Animation<double> _titleIn;
  late final Animation<double> _subtitleIn;
  late final Animation<double> _cardIn;

  AuthMode _mode = AuthMode.login;
  _SubmitState _submitState = _SubmitState.idle;
  final List<Timer> _timers = [];

  /// Shown under their field after a failed submit; cleared as soon as the
  /// value becomes valid again.
  String? _nameError;
  String? _phoneError;

  bool get _phoneValid => _phoneController.text.length == _phoneLength;
  bool get _nameValid => _validateName() == null;

  /// The reason [_nameController]'s text is invalid, or null when it is fine.
  String? _validateName() {
    final name = _nameController.text;
    if (name.isEmpty) return 'Нэвтрэх нэрээ оруулна уу.';
    if (name.length < _nameMinLength) {
      return 'Нэвтрэх нэр дор хаяж $_nameMinLength тэмдэгт байх ёстой.';
    }
    if (!_nameStartsWithLetter.hasMatch(name)) {
      return 'Нэвтрэх нэр үсгээр эхлэх ёстой.';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        if (_nameValid) _nameError = null;
      });
    });
    _phoneController.addListener(() {
      setState(() {
        if (_phoneValid) _phoneError = null;
      });
    });
    _mascotIn = _stagger.slice(0);
    _titleIn = _stagger.slice(0.1);
    _subtitleIn = _stagger.slice(0.16);
    _cardIn = _stagger.slice(0.24);
    _entrance.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced motion: show the finished layout instead of animating it in.
    if (MediaQuery.disableAnimationsOf(context)) _entrance.value = 1;
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _stagger.dispose();
    _entrance.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_submitState != _SubmitState.idle) return;

    // Validate both fields so every problem is shown at once, then focus the
    // topmost offender.
    final nameError = _validateName();
    final phoneError = _phoneValid
        ? null
        : _phoneController.text.isEmpty
        ? 'Гар утасны дугаараа оруулна уу.'
        : 'Утасны дугаар $_phoneLength оронтой байх ёстой.';

    setState(() {
      _nameError = nameError;
      _phoneError = phoneError;
    });

    if (nameError != null) {
      _nameFocus.requestFocus();
      return;
    }
    if (phoneError != null) {
      _phoneFocus.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _submitState = _SubmitState.sending);
    // TODO: replace the simulated delays with the real OTP request.
    _timers.add(
      Timer(const Duration(milliseconds: 900), () {
        setState(() => _submitState = _SubmitState.sent);
        _timers.add(Timer(const Duration(milliseconds: 700), _openOtp));
      }),
    );
  }

  Future<void> _openOtp() async {
    await context.push(AppRoutes.otp, extra: _phoneController.text);
    if (mounted) setState(() => _submitState = _SubmitState.idle);
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _mode == AuthMode.login;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              const _TopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 448),
                      child: Column(
                        children: [
                          Entrance(
                            t: _mascotIn,
                            // The mascot leads, and grows in slightly rather
                            // than just sliding.
                            scaleFrom: 0.94,
                            child: const _Mascot(),
                          ),
                          const SizedBox(height: 8),
                          Entrance(
                            t: _titleIn,
                            child: AppText(
                              'Ard KIDS',
                              size: 20,
                              weight: FontWeight.w700,
                              height: 1.25,
                              letterSpacing: -0.4,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Entrance(
                            t: _subtitleIn,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 290),
                              child: AppText(
                                'Ухаалаг санхүүгийн аяллаа өнөөдөр эхлүүлээрэй.',
                                size: 12,
                                weight: FontWeight.w500,
                                color: AppColors.slate500,
                                height: 1.6,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Entrance(
                            t: _cardIn,
                            // Travels a little further, so the card reads as
                            // settling into place under the heading.
                            offsetY: 24,
                            child: _buildFormCard(isLogin),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(bool isLogin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.sky100.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.sky500.withValues(alpha: 0.08),
            offset: const Offset(0, 12),
            blurRadius: 36,
            spreadRadius: -6,
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTabs(
            tabs: const [AppTab('Нэвтрэх'), AppTab('Бүртгүүлэх')],
            index: _mode.index,
            onChanged: (i) => setState(() => _mode = AuthMode.values[i]),
          ),
          const SizedBox(height: 16),
          const AppFieldLabel('Нэвтрэх нэр'),
          const SizedBox(height: 6),
          AppInputShell(
            hasError: _nameError != null,
            leading: const Icon(
              Icons.person_outline_rounded,
              size: 18,
              color: AppColors.sky500,
            ),
            trailing: AppFieldTick(visible: _nameValid),
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _phoneFocus.requestFocus(),
              inputFormatters: [
                FilteringTextInputFormatter.allow(_nameAllowed),
                LengthLimitingTextInputFormatter(_nameMaxLength),
              ],
              style: appInputStyle(),
              decoration: appInputDecoration('Тэмүүлэн, Мишээл...'),
            ),
          ),
          AppFieldError(message: _nameError),
          const SizedBox(height: 14),
          const AppFieldLabel('Гар утасны дугаар'),
          const SizedBox(height: 6),
          AppInputShell(
            hasError: _phoneError != null,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  '+976',
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.sky700,
                ),
              ],
            ),
            trailing: AppFieldTick(visible: _phoneValid),
            child: TextField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_phoneLength),
              ],
              style: appInputStyle(letterSpacing: 0.8),
              decoration: appInputDecoration('9911 2345'),
            ),
          ),
          AppFieldError(message: _phoneError),
          const SizedBox(height: 14),
          _HelperNote(
            text: isLogin
                ? 'Таны утсанд 4 оронтой баталгаажуулах нууц код очно.'
                : 'Шинэ бүртгэл үүсгэхэд таны утасны дугаарт баталгаажуулах код илгээнэ.',
          ),
          const SizedBox(height: 18),
          _SubmitButton(
            state: _submitState,
            label: isLogin ? 'Үргэлжлүүлэх' : 'Код авах',
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(color: AppColors.sky100.withValues(alpha: 0.6)),
        ),
      ),
      alignment: Alignment.centerRight,
      child: Image.asset(
        'assets/images/ard_logo.png',
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        semanticLabel: 'Ard',
      ),
    );
  }
}

class _Mascot extends StatelessWidget {
  const _Mascot();

  @override
  Widget build(BuildContext context) {
    // The source image has a white background; multiplying with the page
    // surface color blends it in (same as `mix-blend-mode: multiply`).
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Image.asset(
        'assets/images/mascot_red_panda.jpg',
        width: 160,
        height: 160,
        fit: BoxFit.contain,
        color: AppColors.surface,
        colorBlendMode: BlendMode.multiply,
        semanticLabel: 'Ard KIDS улаан панда',
      ),
    );
  }
}

class _HelperNote extends StatelessWidget {
  const _HelperNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.sky50.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sky100.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            size: 18,
            color: AppColors.sky500,
          ),
          const SizedBox(width: 8),
          Expanded(
            // The copy changes with the mode, so cross-fade it instead of
            // snapping to the new sentence.
            child: AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: appEmphasizedDecelerate,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: appEmphasizedDecelerate,
                switchOutCurve: appEmphasizedAccelerate,
                child: AppText(
                  text,
                  size: 11,
                  weight: FontWeight.w500,
                  color: AppColors.sky800,
                  height: 1.25,
                  key: ValueKey(text),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  const _SubmitButton({
    required this.state,
    required this.label,
    required this.onPressed,
  });

  final _SubmitState state;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final busy = widget.state != _SubmitState.idle;
    final textStyle = comfortaa(
      size: 14,
      weight: FontWeight.w700,
      color: Colors.white,
    );

    final Widget content = switch (widget.state) {
      _SubmitState.idle => Row(
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
      _SubmitState.sending => Row(
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
      _SubmitState.sent => Row(
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
      onTap: busy ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          opacity: busy ? 0.8 : 1,
          duration: const Duration(milliseconds: 200),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: [AppColors.sky500, AppColors.sky500, AppColors.sky600],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sky500.withValues(alpha: 0.35),
                  offset: const Offset(0, 8),
                  blurRadius: 20,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _ParentNote extends StatelessWidget {
  const _ParentNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.emerald50.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.emerald200.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(
              color: AppColors.emerald100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              size: 16,
              color: AppColors.emerald600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppText(
              'Эцэг эхийн зөвшөөрөлтэй, хүүхдэд зориулсан 100% найдвартай аюулгүй санхүүгийн платформ.',
              size: 11,
              weight: FontWeight.w500,
              color: AppColors.emerald800,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
