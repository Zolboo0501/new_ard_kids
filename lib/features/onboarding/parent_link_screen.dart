import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:new_ard_kids/features/auth/presentation/widgets/header.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_text.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/entrance.dart';
import '../../app/avatar.dart';

/// "Эцэг эхийн холболт": send a link request to a parent/guardian.
class ParentLinkScreen extends StatefulWidget {
  const ParentLinkScreen({super.key});

  @override
  State<ParentLinkScreen> createState() => _ParentLinkScreenState();
}

class _ParentLinkScreenState extends State<ParentLinkScreen> {
  static const _phoneLength = 8;
  static const _registerLength = 10;

  /// Mongolian register numbers are two Cyrillic letters then eight digits.
  static final _registerShape = RegExp(r'^[А-ЯЁӨҮ]{2}[0-9]{8}$');

  final _phone = TextEditingController();
  final _register = TextEditingController();
  final _phoneFocus = FocusNode();
  final _registerFocus = FocusNode();
  int _role = 0;

  /// Shown under their field after a failed submit; cleared as soon as the
  /// value becomes valid again.
  String? _phoneError;
  String? _registerError;

  static List<(String, String)> get _roles => [
    ('Ээж', Stickers.mom),
    ('Аав', Stickers.dad),
  ];

  @override
  void initState() {
    super.initState();
    _phone.addListener(() {
      setState(() {
        if (_phoneValid) _phoneError = null;
      });
    });
    _register.addListener(() {
      setState(() {
        if (_registerValid) _registerError = null;
      });
    });
  }

  @override
  void dispose() {
    _phone.dispose();
    _register.dispose();
    _phoneFocus.dispose();
    _registerFocus.dispose();
    super.dispose();
  }

  bool get _phoneValid => _validatePhone() == null;
  bool get _registerValid => _validateRegister() == null;
  bool get _valid => _phoneValid && _registerValid;

  String? _validatePhone() {
    final v = _phone.text;
    if (v.isEmpty) return 'Эцэг эхийн утасны дугаарыг оруулна уу.';
    if (v.length != _phoneLength) {
      return 'Утасны дугаар $_phoneLength оронтой байх ёстой.';
    }
    return null;
  }

  String? _validateRegister() {
    final v = _register.text;
    if (v.isEmpty) return 'Өөрийн регистрийн дугаарыг оруулна уу.';
    if (v.length != _registerLength) {
      return 'Регистрийн дугаар $_registerLength тэмдэгт байх ёстой.';
    }
    if (!_registerShape.hasMatch(v)) {
      return 'Регистрийн дугаар 2 үсэг, 8 тооноос бүрдэнэ.';
    }
    return null;
  }

  void _goHome({required bool linked}) {
    context.go(linked ? AppRoutes.home : AppRoutes.homeUnlinked);
  }

  Future<void> _submit() async {
    // Validate both fields so every problem shows at once, then focus the
    // topmost offender.
    final phoneError = _validatePhone();
    final registerError = _validateRegister();
    setState(() {
      _phoneError = phoneError;
      _registerError = registerError;
    });
    if (phoneError != null) {
      _phoneFocus.requestFocus();
      return;
    }
    if (registerError != null) {
      _registerFocus.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();
    // TODO: send the link request to the backend.
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SuccessSheet(),
    );
    if (mounted) _goHome(linked: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dsSurface,
      // No appBar: the shared onboarding Header scrolls with the content, the
      // way it does on the other steps.
      body: SafeArea(
        bottom: false,
        child: EntranceScope(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: EntranceItem.list([
              Header(
                step: 'Алхам 4/4',
                trailing: GestureDetector(
                  onTap: withHaptic(() => _goHome(linked: false)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const AppText(
                      'Алгасах',
                      size: 11,
                      weight: FontWeight.w600,
                      color: AppColors.slate600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: MascotImage(
                  asset: Stickers.family,
                  size: 140,
                  background: AppColors.dsSurface,
                  semanticLabel: 'Гэр бүлийн маскот',
                ),
              ),
              const SizedBox(height: 6),

              Text.rich(
                TextSpan(
                  text: 'Эцэг эхтэйгээ холбогдоод эрхээ ',
                  children: [
                    TextSpan(
                      text: '5 дахин',
                      style:
                          inter(
                            size: 20,
                            weight: FontWeight.w800,
                            color: AppColors.sky500,
                          ).copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.sky300,
                            decorationThickness: 2,
                          ),
                    ),
                    const TextSpan(text: ' нэмэгдүүлээрэй!'),
                  ],
                ),
                textAlign: TextAlign.center,
                style: inter(size: 20, weight: FontWeight.w800, height: 1.4),
              ),
              const SizedBox(height: 16),
              _LimitCard(
                icon: Icons.lock_outline_rounded,
                title: 'Одоогийн эрх',
                subtitle: 'Холбогдоогүй',
                badge: const StatusBadge(
                  label: 'Хязгаарлагдмал',
                  tone: BadgeTone.slate,
                  dot: true,
                ),
                muted: true,
                stats: const [
                  ('Өдрийн зарцуулалт', 20000, null),
                  ('Өдрийн гүйлгээ', '2 удаа', null),
                ],
                footer: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.slate500,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: AppText(
                        'Зөвхөн бэлэн мөнгө зарцуулах анхан шатны эрхтэй',
                        size: 11,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _LimitCard(
                icon: Icons.verified_sharp,
                title: 'Эцэг эх холбогдсоны дараа',
                subtitle: 'Бүрэн боломж нээгдэнэ',
                badge: const StatusBadge(
                  label: 'Бүрэн эрх',
                  tone: BadgeTone.emerald,
                ),
                muted: false,
                stats: const [
                  ('Өдрийн зарцуулалт', (100000, '+'), BadgeTone.sky),
                  ('Өдрийн гүйлгээ', 'Хязгааргүй', BadgeTone.emerald),
                ],
                footer: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.amber50.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.amber200.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.redeem_outlined,
                        color: AppColors.amber800,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText(
                          'Хүүхдийн хадгаламж, койн, урамшуулал авах боломжтой болно!',
                          size: 11,
                          weight: FontWeight.w600,
                          color: AppColors.amber800,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AppCard(
                radius: 20,
                padding: const EdgeInsets.all(16),
                borderColor: AppColors.slate100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText(
                      'Холбогдох асран хамгаалагчаа сонгоно уу',
                      size: 13,
                      weight: FontWeight.w700,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final (i, r) in _roles.indexed) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _RoleButton(
                              label: r.$1,
                              asset: r.$2,
                              selected: _role == i,
                              onTap: () => setState(() => _role = i),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    const AppFieldLabel('Эцэг / Эхийн утасны дугаар'),
                    const SizedBox(height: 6),
                    AppInputShell(
                      hasError: _phoneError != null,
                      leading: AppText(
                        '+976',
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.sky700,
                      ),
                      trailing: AppFieldTick(visible: _phoneValid),
                      child: TextField(
                        controller: _phone,
                        onTapOutside: dismissKeyboard,
                        focusNode: _phoneFocus,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _registerFocus.requestFocus(),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(_phoneLength),
                        ],
                        style: appInputStyle(letterSpacing: 0.8),
                        decoration: appInputDecoration('9909 ••••'),
                      ),
                    ),
                    AppFieldError(message: _phoneError),
                    const SizedBox(height: 14),
                    const AppFieldLabel('Өөрийн регистрийн дугаар'),
                    const SizedBox(height: 6),
                    AppInputShell(
                      hasError: _registerError != null,
                      leading: AppText(
                        'РД',
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.sky700,
                      ),
                      trailing: AppFieldTick(visible: _registerValid),
                      child: TextField(
                        controller: _register,
                        onTapOutside: dismissKeyboard,
                        focusNode: _registerFocus,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        enableSuggestions: false,
                        onSubmitted: (_) => _submit(),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(_registerLength),
                          _UpperCaseFormatter(),
                        ],
                        style: appInputStyle(letterSpacing: 0.8),
                        decoration: appInputDecoration('УХ12345678'),
                      ),
                    ),
                    AppFieldError(message: _registerError),
                    const SizedBox(height: 14),
                    const InfoNote(
                      tone: BadgeTone.slate,
                      icon: Icons.notifications_active_outlined,
                      text:
                          'Таны хүсэлт аав, ээжийн апп дээр очих бөгөөд зөвшөөрснөөр дансны эрх автоматаар нэмэгдэнэ.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Always tappable: pressing it with a bad field is how the user
              // finds out what is wrong, so gating it would hide the message.
              AnimatedOpacity(
                opacity: _valid ? 1 : 0.6,
                duration: const Duration(milliseconds: 200),
                child: PrimaryButton(
                  label: 'Эцэг эх рүү хүсэлт илгээх',
                  height: 56,
                  onPressed: _submit,
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => _goHome(linked: false),
                icon: const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: AppColors.slate500,
                ),
                label: AppText(
                  'Дараа холбох (Хязгаарлагдмал эрхээр орох)',
                  size: 12,
                  weight: FontWeight.w600,
                  color: AppColors.slate500,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}

class _LimitCard extends StatelessWidget {
  const _LimitCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.muted,
    required this.stats,
    required this.footer,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget badge;
  final bool muted;

  /// `(label, value, tone)`; see [_StatBox.value].
  final List<(String, Object, BadgeTone?)> stats;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: muted ? AppColors.slate100.withValues(alpha: 0.8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: muted
              ? AppColors.slate200.withValues(alpha: 0.7)
              : AppColors.emerald200.withValues(alpha: 0.8),
        ),
        boxShadow: muted
            ? null
            : [
                BoxShadow(
                  color: AppColors.emerald500.withValues(alpha: 0.18),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                  spreadRadius: -8,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: muted ? AppColors.slate200 : AppColors.emerald100,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: muted ? AppColors.slate500 : AppColors.emerald600,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(title, size: 13, weight: FontWeight.w700),
                    AppText(
                      subtitle,
                      size: 11,
                      weight: muted ? FontWeight.w500 : FontWeight.w700,
                      color: muted ? AppColors.slate500 : AppColors.emerald600,
                    ),
                  ],
                ),
              ),
              badge,
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final (i, s) in stats.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _StatBox(label: s.$1, value: s.$2, tone: s.$3),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          footer,
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, this.tone});

  final String label;

  /// An amount, an `(amount, suffix)` pair such as `(100000, '+')`, or text.
  final Object value;
  final BadgeTone? tone;

  @override
  Widget build(BuildContext context) {
    final colors = tone?.colors;
    final color = colors?.$2 ?? AppColors.slate800;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors?.$1 ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors?.$3 ?? AppColors.slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            size: 11,
            weight: FontWeight.w500,
            color: colors?.$2 ?? AppColors.slate500,
          ),
          const SizedBox(height: 2),
          // Shrinks rather than overflowing in the half-width box.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: switch (value) {
              final num amount => _amount(amount, color),
              (final num amount, final String suffix) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _amount(amount, color),
                  Text(suffix, style: _textStyle(color)),
                ],
              ),
              _ => Text('$value', style: _textStyle(color)),
            },
          ),
        ],
      ),
    );
  }

  static Widget _amount(num amount, Color color) => BalanceText(
    amount,
    space: false,
    size: 14,
    weight: FontWeight.w500,
    color: color,
  );

  static TextStyle _textStyle(Color color) =>
      moneyStyle(size: 14, weight: FontWeight.w500, color: color);
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.label,
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.sky50 : Colors.white;
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 56,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.sky500 : AppColors.slate200,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MascotImage(
                    asset: asset,
                    size: 36,
                    background: bg,
                    semanticLabel: '',
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: AppText(
                      label,
                      size: 14,
                      weight: FontWeight.w700,
                      color: selected ? AppColors.sky700 : AppColors.slate600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // The same corner tick the other pickers use.
            if (selected)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.sky500,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SuccessSheet extends StatelessWidget {
  const _SuccessSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.emerald100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 30,
                color: AppColors.emerald600,
              ),
            ),
            const SizedBox(height: 12),
            AppText(
              'Хүсэлт амжилттай илгээгдлээ!',
              size: 16,
              weight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            AppText(
              'Таны сонгосон асран хамгаалагч руу мэдэгдэл илгээгдлээ. Зөвшөөрсний дараа таны эрх шууд 5 дахин нэмэгдэх болно.',
              size: 12,
              color: AppColors.slate500,
              height: 1.6,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Ойлголоо',
              height: 50,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
