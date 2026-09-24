import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/biometrics.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_input.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/auth_mascot.dart';
import '../widgets/helper_note.dart';
import '../widgets/mode_switch.dart';
import '../widgets/submit_button.dart';
import '../widgets/top_bar.dart';

enum AuthMode { login, register }

/// "Нэвтрэх & Бүртгүүлэх" screen from the Stitch project.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

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
  SubmitState _submitState = SubmitState.idle;

  /// Set when biometric sign-in is on (Security screen) and the device has an
  /// enrolled biometric; shows the biometric button under Нэвтрэх.
  BiometricKind? _biometric;
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
    if (appBiometricLogin.value) _checkBiometric();
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
    final result = await Biometrics.instance.authenticate(
      'Ard KIDS руу нэвтрэх',
    );
    if (!mounted) return;
    // TODO: restore the saved session instead of signing straight in.
    if (result == BiometricResult.success) return context.go(AppRoutes.home);
    if (result.message case final message?) showAppSnack(context, message);
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
    if (_submitState != SubmitState.idle) return;

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

  @override
  Widget build(BuildContext context) {
    // Short phones (SE, small Androids) shrink the hero so the submit button
    // stays above the fold.
    final compact = MediaQuery.sizeOf(context).height < 720;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              const TopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, compact ? 0 : 8, 20, 24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 448),
                      child: Column(
                        children: [
                          Entrance(
                            t: _mascotIn,
                            // The mascot leads, and grows in slightly
                            // rather than just sliding.
                            scaleFrom: 0.94,
                            child: AuthMascot(size: compact ? 110 : 156),
                          ),
                          SizedBox(height: compact ? 12 : 18),
                          Entrance(
                            t: _titleIn,
                            child: Text.rich(
                              TextSpan(
                                text: 'Ard ',
                                children: [
                                  TextSpan(
                                    text: 'KIDS',
                                    style: inter(
                                      size: compact ? 24 : 28,
                                      weight: FontWeight.w800,
                                      color: AppColors.sky500,
                                      height: 1.15,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              style: inter(
                                size: compact ? 24 : 28,
                                weight: FontWeight.w800,
                                color: AppColors.slate800,
                                height: 1.15,
                                letterSpacing: -0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Entrance(
                            t: _subtitleIn,
                            // Narrow enough that the sentence breaks
                            // into two even lines, not a lone last word.
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 240),
                              child: AppText(
                                'Ухаалаг санхүүгийн аяллаа өнөөдөр эхлүүлээрэй.',
                                size: 13,
                                weight: FontWeight.w500,
                                color: AppColors.slate500,
                                height: 1.5,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 16 : 24),
                          Entrance(
                            t: _cardIn,
                            // Travels a little further, so the card reads
                            // as settling into place under the heading.
                            offsetY: 24,
                            child: _buildFormCard(),
                          ),
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

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
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
          const SizedBox(height: 18),
          ModeSwitch(
            index: _mode.index,
            builder: (shown) => _buildFields(AuthMode.values[shown]),
          ),
        ],
      ),
    );
  }

  /// Everything under the tabs; [mode] is the one currently shown, which
  /// trails [_mode] by half a switch (see [ModeSwitch]).
  Widget _buildFields(AuthMode mode) {
    final isLogin = mode == AuthMode.login;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppFieldLabel('Нэвтрэх нэр'),
        const SizedBox(height: 6),
        AppInputShell(
          hasError: _nameError != null,
          leading: Icon(
            Icons.person_outline_rounded,
            size: 18,
            color: AppColors.sky500,
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
            icon: kind.icon,
            onPressed: _biometricLogin,
          ),
        ],
      ],
    );
  }
}
