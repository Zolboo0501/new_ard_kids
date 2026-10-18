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
import '../../../../widgets/input_formatters.dart';
import '../../../../widgets/register_number_field.dart';
import '../../../../widgets/ui.dart';
import '../../data/sign_up_draft.dart';
import '../widgets/header.dart';
import '../widgets/helper_note.dart';
import '../widgets/mode_switch.dart';
import '../widgets/submit_button.dart';

enum AuthMode { login, register }

/// Бүртгүүлэх asks one thing per page, in this order.
enum _RegisterStep { registerNumber, name, phone }

/// "Нэвтрэх & Бүртгүүлэх": the sign-in screen. Нэвтрэх is an open form
/// under the Ard Kids logo; Бүртгүүлэх asks one question per page (register
/// number, login name, phone) with the button at the bottom. The other mode
/// is a link at the bottom of each.
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
  late final Animation<double> _titleIn;
  late final Animation<double> _cardIn;

  late AuthMode _mode = widget.initialMode;
  _RegisterStep _step = _RegisterStep.registerNumber;
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

  /// The phone number's digits; the field shows them grouped ("8800 2345").
  String get _phoneDigits => _phoneController.text.replaceAll(' ', '');
  bool get _phoneValid => _phoneDigits.length == _phoneLength;
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
    _titleIn = _stagger.slice(0);
    _cardIn = _stagger.slice(0.16);
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

  /// The reason the phone number is invalid, or null when it is fine.
  String? _validatePhone() => _phoneValid
      ? null
      : _phoneDigits.isEmpty
      ? 'Гар утасны дугаараа оруулна уу.'
      : 'Утасны дугаар $_phoneLength оронтой байх ёстой.';

  /// Нэвтрэх: validates both fields so every problem shows at once, focuses
  /// the topmost offender, then signs in.
  void _submit() {
    if (_submitState != SubmitState.idle) return;
    final nameError = _validateName();
    final phoneError = _validatePhone();
    setState(() {
      _nameError = nameError;
      _phoneError = phoneError;
    });
    if (nameError != null) return _nameFocus.requestFocus();
    if (phoneError != null) return _phoneFocus.requestFocus();

    FocusScope.of(context).unfocus();
    setState(() => _submitState = SubmitState.sending);
    // TODO: replace the simulated delay with the real sign-in request.
    _timers.add(
      Timer(
        const Duration(milliseconds: 900),
        () => context.go(AppRoutes.home),
      ),
    );
  }

  /// Бүртгүүлэх's button: checks only the page's own question, then moves
  /// on, and on the last page sends the code.
  void _next() {
    if (_submitState != SubmitState.idle) return;
    switch (_step) {
      case _RegisterStep.registerNumber:
        final error = RegisterNumberField.validate(
          _registerLetters,
          _registerDigitsController.text,
        );
        setState(() => _registerError = error);
        if (error == null) return _goTo(_RegisterStep.name);
        // The letters open a sheet rather than take focus.
        if (_registerLettersValid) _registerDigitsFocus.requestFocus();
      case _RegisterStep.name:
        final error = _validateName();
        setState(() => _nameError = error);
        if (error == null) return _goTo(_RegisterStep.phone);
        _nameFocus.requestFocus();
      case _RegisterStep.phone:
        final error = _validatePhone();
        setState(() => _phoneError = error);
        if (error == null) return _sendCode();
        _phoneFocus.requestFocus();
    }
  }

  /// The header's back on Бүртгүүлэх: the previous question, or Нэвтрэх
  /// from the first.
  void _back() {
    if (_submitState != SubmitState.idle) return;
    if (_step == _RegisterStep.registerNumber) return _setMode(AuthMode.login);
    _goTo(_RegisterStep.values[_step.index - 1]);
  }

  void _goTo(_RegisterStep step) {
    setState(() => _step = step);
    // The field is only attached once the page has swapped in (see
    // [ModeSwitch]), so focus it a moment later. The register number starts
    // with the letter sheet, so it isn't focused.
    final focus = switch (step) {
      _RegisterStep.registerNumber => null,
      _RegisterStep.name => _nameFocus,
      _RegisterStep.phone => _phoneFocus,
    };
    if (focus == null) return FocusScope.of(context).unfocus();
    _timers.add(
      Timer(const Duration(milliseconds: 160), () {
        if (mounted && _step == step) focus.requestFocus();
      }),
    );
  }

  void _sendCode() {
    FocusScope.of(context).unfocus();
    setState(() => _submitState = SubmitState.sending);

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
    await context.push(AppRoutes.otp, extra: _phoneDigits);
    if (mounted) setState(() => _submitState = SubmitState.idle);
  }

  void _setMode(AuthMode mode) {
    if (_mode == mode || _submitState != SubmitState.idle) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _mode = mode;
      _step = _RegisterStep.registerNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomGap = 20 + MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) => ModeSwitch(
              index: _mode.index,
              builder: (shown) => _buildPage(
                constraints,
                bottomGap,
                AuthMode.values[shown] == AuthMode.login
                    ? _buildLogin(constraints)
                    : _buildRegister(constraints),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A scrolling page at least the screen's height, so [children] can push
  /// the mode link to the bottom with a [Spacer].
  Widget _buildPage(
    BoxConstraints constraints,
    double bottomGap,
    List<Widget> children,
  ) {
    return SingleChildScrollView(
      padding: AppLayout.centered(
        EdgeInsets.fromLTRB(24, 8, 24, bottomGap),
        constraints.maxWidth,
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: (constraints.maxHeight - 8 - bottomGap).clamp(
            0.0,
            double.infinity,
          ),
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }

  /// Нэвтрэх: the Ard Kids logo and the form a little above the middle, the
  /// link at the bottom. Spare height on a tall phone is shared out instead
  /// of piling up under the button.
  List<Widget> _buildLogin(BoxConstraints constraints) {
    final compact = constraints.maxHeight < 700;
    return [
      SizedBox(height: compact ? 16 : 24),
      const Spacer(),
      Entrance(
        t: _titleIn,
        child: Center(
          child: Image.asset(
            'assets/images/ard_kids_logo.webp',
            // Grows with the screen's height.
            height: (constraints.maxHeight * 0.22).clamp(120.0, 200.0),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            semanticLabel: 'Ard Kids',
          ),
        ),
      ),
      SizedBox(height: compact ? 24 : 32),
      Entrance(
        t: _cardIn,
        // Travels a little further, so the form reads as settling into
        // place under the logo.
        offsetY: 24,
        child: _buildLoginFields(),
      ),
      const SizedBox(height: 28),
      const Spacer(flex: 2),
      Entrance(t: _cardIn, child: _buildModeLink()),
    ];
  }

  /// Бүртгүүлэх: the step bar, one question with its field, and the button
  /// at the bottom, where the thumb is (and just above the keyboard).
  List<Widget> _buildRegister(BoxConstraints constraints) {
    final compact = constraints.maxHeight < 700;
    final last = _step == _RegisterStep.phone;
    return [
      Header(
        step: 'Алхам 1/6',
        onBack: _back,
        progress: (_step.index + 1) / _RegisterStep.values.length,
      ),
      SizedBox(height: compact ? 16 : 28),
      // Each question slides in from the side, like turning a page.
      ModeSwitch(
        index: _step.index,
        builder: (shown) =>
            _buildQuestion(_RegisterStep.values[shown], compact),
      ),
      const SizedBox(height: 24),
      const Spacer(),
      SubmitButton(
        state: _submitState,
        label: last ? 'Код авах' : 'Дараах',
        onPressed: _next,
      ),
      // The way back to Нэвтрэх, on the first question only; after that
      // the back button walks the questions.
      // Its space stays, so the button doesn't jump between questions.
      const SizedBox(height: 4),
      _step == _RegisterStep.registerNumber
          ? _buildModeLink()
          : const SizedBox(height: 44),
    ];
  }

  /// One sign-up question: a heading that asks it, a line on why, and its
  /// field.
  Widget _buildQuestion(_RegisterStep step, bool compact) {
    final (title, subtitle) = switch (step) {
      _RegisterStep.registerNumber => (
        'Регистрийн дугаараа оруулаарай',
        'Хоёр үсгээ сонгоод, 8 оронтой тоогоо бичээрэй.',
      ),
      _RegisterStep.name => (
        'Нэвтрэх нэрээ сонгоорой',
        'Дараа нь энэ нэр, утасны дугаараараа нэвтэрнэ.',
      ),
      _RegisterStep.phone => (
        'Утасны дугаараа оруулаарай',
        'Энэ дугаар руу 4 оронтой баталгаажуулах код илгээнэ.',
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          title,
          size: compact ? 26 : 30,
          weight: FontWeight.w700,
          color: AppColors.slate900,
          height: 1.15,
          letterSpacing: -0.6,
        ),
        const SizedBox(height: 10),
        AppText(subtitle, size: 15, color: AppColors.slate500, height: 1.45),
        SizedBox(height: compact ? 24 : 32),
        ...switch (step) {
          _RegisterStep.registerNumber => [
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
              onSubmitted: (_) => _next(),
            ),
            AppFieldError(message: _registerError),
          ],
          _RegisterStep.name => [
            _nameField(onSubmitted: _next),
            AppFieldError(message: _nameError),
          ],
          _RegisterStep.phone => [
            _phoneField(onSubmitted: _next),
            AppFieldError(message: _phoneError),
          ],
        },
      ],
    );
  }

  /// "Бүртгэл байхгүй юу? Бүртгүүлэх" (and the reverse): the way to the
  /// other mode, as a link rather than a control. The link is its own text
  /// widget so it reads as a button to assistive tech.
  Widget _buildModeLink() {
    final isLogin = _mode == AuthMode.login;
    return Row(
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
            onTap: () => _setMode(isLogin ? AuthMode.register : AuthMode.login),
            scale: 0.96,
            child: Container(
              // A full 44pt target around a short word.
              constraints: const BoxConstraints(minHeight: 44),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
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
    );
  }

  Widget _nameField({required VoidCallback onSubmitted}) {
    return AppInputShell(
      fill: AppColors.card,
      hasError: _nameError != null,
      leading: LineIcon(LineGlyph.profile, size: 18, color: AppColors.slate500),
      trailing: AppFieldTick(visible: _nameValid),
      child: TextField(
        controller: _nameController,
        onTapOutside: dismissKeyboard,
        focusNode: _nameFocus,
        textInputAction: _mode == AuthMode.login
            ? TextInputAction.next
            : TextInputAction.done,
        onSubmitted: (_) => onSubmitted(),
        // A handle, not prose: nothing should "correct" it.
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: const [AutofillHints.username],
        inputFormatters: [
          FilteringTextInputFormatter.allow(_nameAllowed),
          LengthLimitingTextInputFormatter(_nameMaxLength),
        ],
        style: appInputStyle(),
        decoration: appInputDecoration('Тэмүүлэн, Мишээл...'),
      ),
    );
  }

  Widget _phoneField({required VoidCallback onSubmitted}) {
    return AppInputShell(
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
        onSubmitted: (_) => onSubmitted(),
        // Grouped as it is typed, the way the hint reads.
        inputFormatters: [
          DigitGroupFormatter(const [4, 4]),
        ],
        autofillHints: const [AutofillHints.telephoneNumberNational],
        style: appInputStyle(letterSpacing: 0.8),
        decoration: appInputDecoration('8800 2345'),
      ),
    );
  }

  /// Нэвтрэх's fields, note and button.
  Widget _buildLoginFields() {
    // One autofill group, so the system can offer the saved name and phone
    // together.
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppFieldLabel('Нэвтрэх нэр'),
          const SizedBox(height: 8),
          _nameField(onSubmitted: _phoneFocus.requestFocus),
          AppFieldError(message: _nameError),
          const SizedBox(height: 16),
          const AppFieldLabel('Гар утасны дугаар'),
          const SizedBox(height: 8),
          _phoneField(onSubmitted: _submit),
          AppFieldError(message: _phoneError),
          const SizedBox(height: 16),
          const HelperNote(
            text: 'Таны утсанд 4 оронтой баталгаажуулах нууц код очно.',
          ),
          const SizedBox(height: 20),
          SubmitButton(
            state: _submitState,
            label: 'Үргэлжлүүлэх',
            onPressed: _submit,
          ),
          if (_biometric case final kind?) ...[
            const SizedBox(height: 10),
            SoftButton(
              height: 52,
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
      ),
    );
  }
}
