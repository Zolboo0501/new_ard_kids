import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/biometrics.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_input.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/register_number_field.dart';
import '../../../../widgets/ui.dart';
import '../../../../widgets/value_switcher.dart';
import '../../data/sign_up_draft.dart';
import '../widgets/helper_note.dart';
import '../widgets/mode_switch.dart';
import '../widgets/submit_button.dart';

enum AuthMode { login, register }

/// "Нэвтрэх & Бүртгүүлэх": the sign-in screen. An open form on the canvas
/// under the mode's heading, with the other mode a link at the bottom.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialMode = AuthMode.login});

  final AuthMode initialMode;

  /// Whether the biometric prompt has opened by itself this launch. Only the
  /// first sign-in screen prompts; after a logout the kid taps the button.
  @visibleForTesting
  static bool biometricPrompted = false;

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
  final _registerDigitsController = TextEditingController();
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _registerDigitsFocus = FocusNode();

  /// The two register-number letters, picked from the letter sheet.
  List<String?> _registerLetters = [null, null];

  /// Drives the one-shot entrance: each element fades and rises over its own
  /// slice of this controller (see [Entrance]).
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );

  /// One curved slice per element, built once in [initState].
  late final EntranceStagger _stagger = EntranceStagger(_entrance);
  late final Animation<double> _logoIn;
  late final Animation<double> _titleIn;
  late final Animation<double> _subtitleIn;
  late final Animation<double> _cardIn;

  late AuthMode _mode = widget.initialMode;
  SubmitState _submitState = SubmitState.idle;

  /// Set when biometric sign-in is on (Security screen) and the device has an
  /// enrolled biometric; shows the biometric button under Нэвтрэх.
  BiometricKind? _biometric;

  /// Why the last biometric prompt didn't sign in, shown under its button.
  /// Inline rather than a snack bar, which would cover the button the teen
  /// needs to retry with.
  String? _biometricMessage;
  final List<Timer> _timers = [];

  /// Shown under their field after a failed submit; cleared as soon as the
  /// value becomes valid again.
  String? _nameError;
  String? _phoneError;
  String? _registerError;

  bool get _registerLettersValid => !_registerLetters.contains(null);
  bool get _registerValid =>
      RegisterNumberField.validate(
        _registerLetters,
        _registerDigitsController.text,
      ) ==
      null;
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
    _registerDigitsController.addListener(() {
      setState(() {
        if (_registerValid) _registerError = null;
      });
    });
    _logoIn = _stagger.slice(0);
    _titleIn = _stagger.slice(0.1);
    _subtitleIn = _stagger.slice(0.16);
    _cardIn = _stagger.slice(0.24);
    _entrance.forward();
    if (appBiometricLogin.value && _mode == AuthMode.login) _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final kind = await Biometrics.instance.available();
    if (!mounted || kind == null) return;
    setState(() => _biometric = kind);
    if (!AuthScreen.biometricPrompted) {
      AuthScreen.biometricPrompted = true;
      _biometricLogin();
    }
  }

  Future<void> _biometricLogin() async {
    if (_submitState != SubmitState.idle) return;
    setState(() => _biometricMessage = null);
    final result = await Biometrics.instance.authenticate('Ard руу нэвтрэх');
    if (!mounted) return;
    // TODO: restore the saved session instead of signing straight in.
    if (result == BiometricResult.success) return context.go(AppRoutes.home);
    setState(() => _biometricMessage = result.message);
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
    _registerDigitsController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _registerDigitsFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_submitState != SubmitState.idle) return;

    // Validate every field so every problem is shown at once, then focus the
    // topmost offender. The register number is only asked for on Бүртгүүлэх.
    final nameError = _validateName();
    final phoneError = _phoneValid
        ? null
        : _phoneController.text.isEmpty
        ? 'Гар утасны дугаараа оруулна уу.'
        : 'Утасны дугаар $_phoneLength оронтой байх ёстой.';
    final registerError = _mode == AuthMode.login
        ? null
        : RegisterNumberField.validate(
            _registerLetters,
            _registerDigitsController.text,
          );

    setState(() {
      _nameError = nameError;
      _phoneError = phoneError;
      _registerError = registerError;
    });

    if (registerError != null) {
      // The letters open a sheet rather than take focus, so only the digit
      // field is focused.
      if (_registerLettersValid) _registerDigitsFocus.requestFocus();
      return;
    }
    if (nameError != null) {
      _nameFocus.requestFocus();
      return;
    }
    if (phoneError != null) {
      _phoneFocus.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _submitState = SubmitState.sending);

    // Нэвтрэх signs straight in; Бүртгүүлэх goes on to verify the phone.
    if (_mode == AuthMode.login) {
      // TODO: replace the simulated delay with the real sign-in request.
      _timers.add(
        Timer(
          const Duration(milliseconds: 900),
          () => context.go(AppRoutes.home),
        ),
      );
      return;
    }

    // Kept so the parent-link step can prefill the same register number.
    SignUpDraft.registerNumber = RegisterNumber(
      _registerLetters.cast<String>(),
      _registerDigitsController.text,
    );

    // TODO: replace the simulated delays with the real OTP request.
    _timers.add(
      Timer(const Duration(milliseconds: 900), () {
        setState(() => _submitState = SubmitState.sent);
        _timers.add(Timer(const Duration(milliseconds: 700), _openOtp));
      }),
    );
  }

  Future<void> _openOtp() async {
    await context.push(AppRoutes.otp, extra: _phoneController.text);
    if (mounted) setState(() => _submitState = SubmitState.idle);
  }

  void _setMode(AuthMode mode) {
    if (_mode == mode || _submitState != SubmitState.idle) return;
    FocusScope.of(context).unfocus();
    setState(() => _mode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final bottomGap = 20 + padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // On a short screen (iPhone SE) the heading compacts so the
              // fields are in view on arrival.
              final compact = constraints.maxHeight < 700;
              return SingleChildScrollView(
                padding: AppLayout.centered(
                  EdgeInsets.fromLTRB(24, 16, 24, bottomGap),
                  constraints.maxWidth,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  // At least the visible height, so the mode link sits at
                  // the bottom on tall screens and the form reads top-down.
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 16 - bottomGap).clamp(
                      0.0,
                      double.infinity,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Entrance(
                            t: _logoIn,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                'assets/images/ard_logo.png',
                                height: 28,
                                fit: BoxFit.contain,
                                // The mark is black on transparent; tint it
                                // so it follows the canvas in both modes.
                                color: AppColors.slate900,
                                semanticLabel: 'Ard',
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 24 : 40),
                          // The heading and the form travel together when
                          // the mode switches.
                          ModeSwitch(
                            index: _mode.index,
                            builder: (shown) =>
                                _buildBody(AuthMode.values[shown], compact),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Entrance(t: _cardIn, child: _buildModeLink()),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// The mode's heading, a line under it, and its form, straight on the
  /// canvas.
  Widget _buildBody(AuthMode mode, bool compact) {
    final isLogin = mode == AuthMode.login;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Entrance(
          t: _titleIn,
          child: AppText(
            isLogin ? 'Нэвтрэх' : 'Бүртгэл үүсгэх',
            size: compact ? 30 : 36,
            weight: FontWeight.w700,
            color: AppColors.slate900,
            height: 1.08,
            letterSpacing: -0.9,
          ),
        ),
        SizedBox(height: compact ? 8 : 12),
        Entrance(
          t: _subtitleIn,
          child: AppText(
            isLogin
                ? 'Хадгаламж, карт, хувьцаа, урамшуулал бүгд нэг дор. '
                : 'Бүртгэл үүсгэж, өөрийн хадгаламж, карт, хувьцаа, урамшууллын эрхээ аваарай',
            size: 15,
            color: AppColors.slate500,
            height: 1.45,
          ),
        ),
        SizedBox(height: compact ? 24 : 32),
        Entrance(
          t: _cardIn,
          // Travels a little further, so the form reads as settling into
          // place under the heading.
          offsetY: 24,
          child: _buildFields(mode),
        ),
      ],
    );
  }

  /// "Бүртгэл байхгүй юу? Бүртгүүлэх" under the form (and the reverse):
  /// the way to the other mode, as a link rather than a control. The link
  /// is its own text widget so it reads as a button to assistive tech.
  Widget _buildModeLink() {
    final isLogin = _mode == AuthMode.login;
    return ValueSwitcher(
      value: _mode,
      duration: const Duration(milliseconds: 200),
      child: Row(
        key: ValueKey(_mode),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            isLogin ? 'Бүртгэл байхгүй юу?' : 'Бүртгэлтэй юу?',
            size: 14,
            color: AppColors.slate500,
          ),
          const SizedBox(width: 6),
          Semantics(
            button: true,
            child: Pressable(
              onTap: () =>
                  _setMode(isLogin ? AuthMode.register : AuthMode.login),
              scale: 0.96,
              child: Padding(
                // A comfortable target around a short word.
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 10,
                ),
                child: AppText(
                  isLogin ? 'Бүртгүүлэх' : 'Нэвтрэх',
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.sky600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The mode's fields, note and button; [mode] is the one currently shown,
  /// which trails [_mode] by half a switch (see [ModeSwitch]).
  Widget _buildFields(AuthMode mode) {
    final isLogin = mode == AuthMode.login;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isLogin) ...[
          const AppFieldLabel('Регистрийн дугаар'),
          const SizedBox(height: 6),
          RegisterNumberField(
            fill: AppColors.card,
            letters: _registerLetters,
            onLettersChanged: (letters) => setState(() {
              _registerLetters = letters;
              if (_registerValid) _registerError = null;
            }),
            digitsController: _registerDigitsController,
            digitsFocus: _registerDigitsFocus,
            hasError: _registerError != null,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _nameFocus.requestFocus(),
          ),
          AppFieldError(message: _registerError),
          const SizedBox(height: 14),
        ],
        const AppFieldLabel('Нэвтрэх нэр'),
        const SizedBox(height: 6),
        AppInputShell(
          fill: AppColors.card,
          hasError: _nameError != null,
          leading: LineIcon(
            LineGlyph.profile,
            size: 18,
            color: AppColors.slate500,
          ),
          trailing: AppFieldTick(visible: _nameValid),
          child: TextField(
            controller: _nameController,
            onTapOutside: dismissKeyboard,
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
          fill: AppColors.card,
          hasError: _phoneError != null,
          leading: AppText(
            '+976',
            size: 14,
            weight: FontWeight.w600,
            color: AppColors.slate600,
          ),
          trailing: AppFieldTick(visible: _phoneValid),
          child: TextField(
            controller: _phoneController,
            onTapOutside: dismissKeyboard,
            focusNode: _phoneFocus,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(_phoneLength),
            ],
            style: appInputStyle(letterSpacing: 0.8),
            decoration: appInputDecoration('8800 2345'),
          ),
        ),
        AppFieldError(message: _phoneError),
        const SizedBox(height: 12),
        HelperNote(
          text: isLogin
              ? 'Таны утсанд 4 оронтой баталгаажуулах нууц код очно.'
              : 'Шинэ бүртгэл үүсгэхэд таны утасны дугаарт баталгаажуулах код илгээнэ.',
        ),
        const SizedBox(height: 16),
        SubmitButton(
          state: _submitState,
          label: isLogin ? 'Үргэлжлүүлэх' : 'Код авах',
          onPressed: _submit,
        ),
        if (_biometric case final kind? when isLogin) ...[
          const SizedBox(height: 10),
          SoftButton(
            label: kind.loginLabel,
            leading: LineIcon(
              kind == BiometricKind.face
                  ? LineGlyph.faceId
                  : LineGlyph.fingerprint,
              size: 20,
              color: AppColors.sky600,
            ),
            onPressed: _biometricLogin,
          ),
          if (_biometricMessage case final message?) ...[
            const SizedBox(height: 8),
            AppText(
              message,
              size: 12,
              color: AppColors.slate500,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ],
    );
  }
}
