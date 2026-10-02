import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/biometrics.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../../../app/kid_profile.dart';
import '../../../../widgets/entrance.dart';
import '../widgets/confirm_button.dart';
import '../widgets/field_error.dart';
import '../widgets/header.dart';
import '../widgets/header_skip_button.dart';
import '../widgets/username_field.dart';

/// "Найзын хүсэлт" screen: send a friend request by username.
class FriendCodeScreen extends StatefulWidget {
  const FriendCodeScreen({super.key});

  @override
  State<FriendCodeScreen> createState() => _FriendCodeScreenState();
}

class _FriendCodeScreenState extends State<FriendCodeScreen>
    with SingleTickerProviderStateMixin {
  static const _minLength = 2;
  static const _maxLength = 20;

  /// Same shape as the user's own handle on the sign-in screen: Cyrillic
  /// (incl. Өө/Үү/Ёё) and Latin letters, digits and `_`, starting with a
  /// letter.
  static final _allowed = RegExp(r'[A-Za-zА-Яа-яЁёӨөҮү0-9_]');
  static final _startsWithLetter = RegExp(r'^[A-Za-zА-Яа-яЁёӨөҮү]');

  final _username = TextEditingController();
  final _usernameFocus = FocusNode();

  /// Shown under the field after a failed send; cleared once valid again.
  String? _error;

  bool get _valid => _validate() == null;

  /// The reason [_username]'s text is invalid, or null when it is fine.
  String? _validate() {
    final name = _username.text.trim();
    if (name.isEmpty) return 'Найзынхаа нэвтрэх нэрийг оруулна уу.';
    if (name.length < _minLength) {
      return 'Нэвтрэх нэр дор хаяж $_minLength тэмдэгт байх ёстой.';
    }
    if (!_startsWithLetter.hasMatch(name)) {
      return 'Нэвтрэх нэр үсгээр эхлэх ёстой.';
    }
    return null;
  }

  /// Drives the one-shot entrance: each element fades and rises over its own
  /// slice of this controller (see [Entrance]).
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  late final EntranceStagger _stagger = EntranceStagger(_entrance);
  late final Animation<double> _headerIn;
  late final Animation<double> _heroIn;
  late final Animation<double> _cardIn;
  late final Animation<double> _buttonIn;

  /// Guards against re-focusing if the entrance reports completion more than
  /// once, or if the user has already moved focus elsewhere.
  bool _autofocused = false;

  @override
  void initState() {
    super.initState();
    _headerIn = _stagger.slice(0);
    _heroIn = _stagger.slice(0.06);
    _cardIn = _stagger.slice(0.14);
    _buttonIn = _stagger.slice(0.26);
    // Focus the field once the card has finished animating in, rather than
    // `autofocus: true`, which would raise the keyboard over a screen that is
    // still drawing itself.
    _entrance.addStatusListener(_autofocusWhenSettled);
    _entrance.forward();
    _username.addListener(() {
      setState(() {
        if (_valid) _error = null;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced motion: show the finished layout instead of animating it in.
    // Setting the value reports `completed`, so the field still gets focus.
    if (MediaQuery.disableAnimationsOf(context)) _entrance.value = 1;
  }

  void _autofocusWhenSettled(AnimationStatus status) {
    if (status != AnimationStatus.completed || _autofocused || !mounted) return;
    _autofocused = true;
    _usernameFocus.requestFocus();
  }

  @override
  void dispose() {
    _entrance.removeStatusListener(_autofocusWhenSettled);
    _stagger.dispose();
    _entrance.dispose();
    _username.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  Future<void> _finish({required bool skipped}) async {
    if (!skipped) {
      final error = _validate();
      if (error != null) {
        setState(() => _error = error);
        _usernameFocus.requestFocus();
        return;
      }
      FocusScope.of(context).unfocus();
      // TODO: send the friend request to the backend.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: AppText(
              '${_username.text.trim()} рүү найзын хүсэлт илгээлээ',
              size: 13,
              color: AppColors.slate900,
            ),
          ),
        );
    }
    // Offers biometric sign-in next, unless the phone has no sensor for it;
    // that is the last step, so without one registration is already done.
    final hasSensor = await Biometrics.instance.hasSensor();
    if (!mounted) return;
    if (hasSensor) {
      context.push(AppRoutes.biometricSetup);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: AdaptiveCenter(child: _buildContent()),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Entrance(
          t: _headerIn,
          child: Header(
            step: 'Алхам 4/5',
            trailing: HeaderSkipButton(onPressed: () => _finish(skipped: true)),
          ),
        ),
        const SizedBox(height: 12),
        Entrance(t: _heroIn, child: _buildIntro()),
        const SizedBox(height: 24),
        Entrance(t: _cardIn, offsetY: 22, child: _buildUsernameCard()),
        const SizedBox(height: 16),
        Entrance(
          t: _buttonIn,
          offsetY: 22,
          child: ConfirmButton(
            // Always tappable: pressing it with an invalid name is how the
            // user finds out what is wrong, so gating it would hide the
            // message entirely.
            dimmed: !_valid,
            onPressed: () => _finish(skipped: false),
          ),
        ),
      ],
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Найзаа нэмэх',
          size: 28,
          weight: FontWeight.w700,
          color: AppColors.slate900,
          height: 1.2,
          letterSpacing: -0.6,
        ),
        const SizedBox(height: 8),
        AppText(
          'Найзынхаа нэвтрэх нэрийг оруулаад хүсэлт илгээ.',
          size: 15,
          color: AppColors.slate500,
          height: 1.45,
        ),
      ],
    );
  }

  Widget _buildUsernameCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UsernameField(
            controller: _username,
            focusNode: _usernameFocus,
            hasError: _error != null,
            allowed: _allowed,
            maxLength: _maxLength,
            onSubmitted: () => _finish(skipped: false),
          ),
          FieldError(message: _error),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LineIcon(LineGlyph.gift, size: 18, color: AppColors.slate500),
              const SizedBox(width: 10),
              Expanded(
                child: AppText(
                  'Хүсэлт баталгаажвал та хоёр тус бүр '
                  '${formatMnt(Limits.inviteBonus)} авна.',
                  size: 13,
                  color: AppColors.slate500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
