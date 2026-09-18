import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';

enum AuthMode { login, register }

enum _SubmitState { idle, sending, sent }

/// "Нэвтрэх & Бүртгүүлэх" screen from the Stitch project.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
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
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
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
                          const _Mascot(),
                          const SizedBox(height: 8),
                          Text(
                            'Ard KIDS',
                            textAlign: TextAlign.center,
                            style: comfortaa(
                              size: 20,
                              weight: FontWeight.w700,
                              height: 1.25,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 290),
                            child: Text(
                              'Ухаалаг санхүүгийн аяллаа өнөөдөр эхлүүлээрэй.',
                              textAlign: TextAlign.center,
                              style: comfortaa(
                                size: 12,
                                weight: FontWeight.w500,
                                color: AppColors.slate500,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildFormCard(isLogin),
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
      padding: const EdgeInsets.all(20),
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
          _ModeSwitcher(
            mode: _mode,
            onChanged: (mode) => setState(() => _mode = mode),
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Нэвтрэх нэр'),
          const SizedBox(height: 6),
          _InputShell(
            hasError: _nameError != null,
            leading: const Icon(
              Icons.person_outline_rounded,
              size: 18,
              color: AppColors.sky500,
            ),
            trailing: AnimatedOpacity(
              opacity: _nameValid ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: AppColors.emerald500,
                ),
              ),
            ),
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _phoneFocus.requestFocus(),
              inputFormatters: [
                FilteringTextInputFormatter.allow(_nameAllowed),
                LengthLimitingTextInputFormatter(_nameMaxLength),
              ],
              style: _inputStyle,
              decoration: _inputDecoration('Тэмүүлэн, Мишээл...'),
            ),
          ),
          _FieldError(message: _nameError),
          const SizedBox(height: 14),
          const _FieldLabel('Гар утасны дугаар'),
          const SizedBox(height: 6),
          _InputShell(
            hasError: _phoneError != null,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇲🇳', style: TextStyle(fontSize: 14, height: 1)),
                const SizedBox(width: 6),
                Text(
                  '+976',
                  style: comfortaa(
                    size: 12,
                    weight: FontWeight.w700,
                    color: AppColors.sky700,
                  ),
                ),
              ],
            ),
            trailing: AnimatedOpacity(
              opacity: _phoneValid ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: AppColors.emerald500,
                ),
              ),
            ),
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
              style: _inputStyle.copyWith(letterSpacing: 0.8),
              decoration: _inputDecoration('9911 2345'),
            ),
          ),
          _FieldError(message: _phoneError),
          const SizedBox(height: 14),
          _HelperNote(
            text: isLogin
                ? 'Таны утсанд 4 оронтой баталгаажуулах нууц код очно.'
                : 'Шинэ бүртгэл үүсгэхэд таны утасны дугаарт баталгаажуулах код илгээнэ.',
          ),
          const SizedBox(height: 18),
          _SubmitButton(
            state: _submitState,
            label: isLogin ? 'Үргэлжлүүлэх 🚀' : 'Код авах ✨',
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  TextStyle get _inputStyle => comfortaa(size: 14, weight: FontWeight.w700);

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      isDense: true,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      hintText: hint,
      hintStyle: comfortaa(size: 14, color: AppColors.slate300),
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

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({required this.mode, required this.onChanged});

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.slate100.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.slate200.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _tab('Нэвтрэх', AuthMode.login),
          _tab('Бүртгүүлэх', AuthMode.register),
        ],
      ),
    );
  }

  Widget _tab(String label, AuthMode value) {
    final selected = mode == value;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: selected
                ? const LinearGradient(
                    colors: [AppColors.sky500, AppColors.sky400],
                  )
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.sky500.withValues(alpha: 0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: comfortaa(
              size: 12,
              weight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.slate500,
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: comfortaa(
          size: 12,
          weight: FontWeight.w700,
          color: AppColors.slate600,
        ),
      ),
    );
  }
}

/// Rounded input container with a white badge on the left; highlights with a
/// sky border and halo while the inner field has focus.
class _InputShell extends StatefulWidget {
  const _InputShell({
    required this.leading,
    required this.child,
    this.trailing,
    this.hasError = false,
  });

  final Widget leading;
  final Widget child;
  final Widget? trailing;

  /// Paints the border and halo red instead of sky.
  final bool hasError;

  @override
  State<_InputShell> createState() => _InputShellState();
}

class _InputShellState extends State<_InputShell> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _focused ? Colors.white : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.hasError
                ? AppColors.rose400
                : _focused
                ? AppColors.sky400
                : AppColors.slate200,
          ),
          boxShadow: widget.hasError || _focused
              ? [
                  BoxShadow(
                    color:
                        (widget.hasError ? AppColors.rose400 : AppColors.sky400)
                            .withValues(alpha: 0.4),
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: widget.leading,
            ),
            const SizedBox(width: 8),
            Expanded(child: widget.child),
            ?widget.trailing,
          ],
        ),
      ),
    );
  }
}

/// Validation message under a field. Collapses to nothing when [message] is
/// null so the card doesn't reserve empty space.
class _FieldError extends StatelessWidget {
  const _FieldError({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 15,
                    color: AppColors.rose500,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      message!,
                      style: comfortaa(
                        size: 11,
                        weight: FontWeight.w600,
                        color: AppColors.rose600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
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
            child: Text(
              text,
              style: comfortaa(
                size: 11,
                weight: FontWeight.w500,
                color: AppColors.sky800,
                height: 1.25,
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
        key: const ValueKey('idle'),
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
          Text('Код илгээгдлээ! ✨', style: textStyle),
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
            child: Text(
              'Эцэг эхийн зөвшөөрөлтэй, хүүхдэд зориулсан 100% найдвартай аюулгүй санхүүгийн платформ.',
              style: comfortaa(
                size: 11,
                weight: FontWeight.w500,
                color: AppColors.emerald800,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
