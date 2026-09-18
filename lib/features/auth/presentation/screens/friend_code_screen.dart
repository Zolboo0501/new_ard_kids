import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:new_ard_kids/features/auth/presentation/widgets/header.dart';

import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/entrance.dart';

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
  late final Animation<double> _bannerIn;
  late final Animation<double> _buttonIn;

  @override
  void initState() {
    super.initState();
    _headerIn = _stagger.slice(0);
    _heroIn = _stagger.slice(0.06);
    _cardIn = _stagger.slice(0.14);
    _bannerIn = _stagger.slice(0.2);
    _buttonIn = _stagger.slice(0.26);
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
    if (MediaQuery.disableAnimationsOf(context)) _entrance.value = 1;
  }

  @override
  void dispose() {
    _stagger.dispose();
    _entrance.dispose();
    _username.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  void _finish({required bool skipped}) {
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
              color: Colors.white,
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
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Center(child: _buildContent()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Entrance(
          t: _headerIn,
          child: const Header(step: 'Алхам 3/4'),
        ),
        const SizedBox(height: 4),
        Entrance(t: _heroIn, child: _buildHeroRow()),
        const SizedBox(height: 12),
        Entrance(t: _cardIn, offsetY: 22, child: _buildUsernameCard()),
        const SizedBox(height: 10),
        Entrance(t: _bannerIn, offsetY: 22, child: const _RewardBanner()),
        const SizedBox(height: 12),
        Entrance(
          t: _buttonIn,
          offsetY: 22,
          child: _ConfirmButton(
            // Always tappable: pressing it with an invalid name is how the
            // user finds out what is wrong, so gating it would hide the
            // message entirely.
            dimmed: !_valid,
            onPressed: () => _finish(skipped: false),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Title and description on the left, mascot on the right.
  Widget _buildHeroRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Найзаа нэмэх',
                size: 22,
                weight: FontWeight.w700,
                height: 1.3,
                letterSpacing: -0.6,
              ),
              const SizedBox(height: 6),
              const AppText(
                'Найзынхаа нэвтрэх нэрийг оруулж хүсэлт илгээгээрэй. Хоёулаа урамшуулал авна!',
                size: 13,
                weight: FontWeight.w500,
                color: AppColors.slate500,
                height: 1.625,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
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
      ],
    );
  }

  Widget _buildUsernameCard() {
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
          _UsernameField(
            controller: _username,
            focusNode: _usernameFocus,
            hasError: _error != null,
            allowed: _allowed,
            maxLength: _maxLength,
            onSubmitted: () => _finish(skipped: false),
          ),
          _FieldError(message: _error),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: const AppText(
              'Найзынхаа нэрийг мэдэхгүй байна уу?',
              size: 12,
              weight: FontWeight.w500,
              color: AppColors.slate400,
            ),
          ),
        ],
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
            const AppText(
              'Алгасах',
              size: 11.5,
              weight: FontWeight.w700,
              color: AppColors.slate500,
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

/// The friend's username. Highlights sky while focused, rose when the last
/// send failed validation.
class _UsernameField extends StatefulWidget {
  const _UsernameField({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.allowed,
    required this.maxLength,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final RegExp allowed;
  final int maxLength;
  final VoidCallback onSubmitted;

  @override
  State<_UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends State<_UsernameField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.hasError ? AppColors.rose400 : AppColors.sky500;

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: appEmphasizedDecelerate,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: _focused ? Colors.white : AppColors.slate50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.hasError
                ? AppColors.rose400
                : _focused
                ? AppColors.sky500
                : AppColors.slate200.withValues(alpha: 0.7),
            width: _focused || widget.hasError ? 2 : 1,
          ),
          boxShadow: _focused || widget.hasError
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(Icons.alternate_email_rounded, size: 18, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                textCapitalization: TextCapitalization.none,
                onSubmitted: (_) => widget.onSubmitted(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(widget.allowed),
                  LengthLimitingTextInputFormatter(widget.maxLength),
                ],
                style: comfortaa(
                  size: 16,
                  weight: FontWeight.w700,
                  color: AppColors.sky700,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintText: 'temuulen_07',
                  hintStyle: comfortaa(size: 16, color: AppColors.slate300),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Validation message under the field. Collapses to nothing when [message] is
/// null so the card does not reserve empty space.
class _FieldError extends StatelessWidget {
  const _FieldError({required this.message});

  final String? message;

  static const _duration = Duration(milliseconds: 240);

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: _duration,
      curve: appEmphasizedDecelerate,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: _duration,
        switchInCurve: appEmphasizedDecelerate,
        switchOutCurve: appEmphasizedAccelerate,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, -0.35),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: message == null
            ? const SizedBox(key: ValueKey('none'), width: double.infinity)
            : Padding(
                key: ValueKey(message),
                padding: const EdgeInsets.only(left: 4, right: 4, top: 8),
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
                      child: AppText(
                        message!,
                        size: 11,
                        weight: FontWeight.w600,
                        color: AppColors.rose600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
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
                    text: 'Хүсэлт баталгаажсанаар та болон таны найз тус бүр ',
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

class _ConfirmButton extends StatefulWidget {
  const _ConfirmButton({required this.dimmed, required this.onPressed});

  /// Fades the button back while the form is incomplete. It stays tappable so
  /// a press can explain what is missing.
  final bool dimmed;
  final VoidCallback onPressed;

  @override
  State<_ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<_ConfirmButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        // Presses in slightly, and settles back up when the username becomes
        // valid and the button enables.
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          curve: appEmphasizedDecelerate,
          child: AnimatedOpacity(
            opacity: widget.dimmed ? 0.6 : 1,
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
                  const AppText(
                    'Хүсэлт илгээх',
                    size: 16,
                    weight: FontWeight.w700,
                    color: Colors.white,
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
      ),
    );
  }
}
