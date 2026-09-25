import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/avatar.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_input.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../../auth/presentation/widgets/header.dart';
import '../widgets/limit_card.dart';
import '../widgets/role_button.dart';
import '../widgets/success_sheet.dart';

/// "Эцэг эхийн холболт": send a link request to a parent/guardian.
///
/// With [onboarding] (the last registration step) the header shows the step
/// pill; opened later from Home or Profile it has none.
class ParentLinkScreen extends StatefulWidget {
  const ParentLinkScreen({super.key, this.onboarding = false});

  final bool onboarding;

  @override
  State<ParentLinkScreen> createState() => _ParentLinkScreenState();
}

class _ParentLinkScreenState extends State<ParentLinkScreen> {
  static const _phoneLength = 8;

  final _phone = TextEditingController();
  final _phoneFocus = FocusNode();
  int _role = 0;

  /// Shown under the field after a failed submit; cleared as soon as the
  /// value becomes valid again.
  String? _phoneError;

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
  }

  @override
  void dispose() {
    _phone.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  bool get _phoneValid => _validatePhone() == null;

  String? _validatePhone() {
    final v = _phone.text;
    if (v.isEmpty) return 'Эцэг эхийн утасны дугаарыг оруулна уу.';
    if (v.length != _phoneLength) {
      return 'Утасны дугаар $_phoneLength оронтой байх ёстой.';
    }
    return null;
  }

  void _goHome({required bool linked}) {
    context.go(linked ? AppRoutes.home : AppRoutes.homeUnlinked);
  }

  Future<void> _submit() async {
    final phoneError = _validatePhone();
    setState(() => _phoneError = phoneError);
    if (phoneError != null) {
      _phoneFocus.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();
    // TODO: send the link request to the backend. The kid's register number
    // comes from their account (SignUpDraft.registerNumber for now), so the
    // screen doesn't ask for it.
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const SuccessSheet(),
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
          child: AdaptiveListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: EntranceItem.list([
              Header(
                step: widget.onboarding ? 'Алхам 6/6' : null,
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
              LimitCard(
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
              LimitCard(
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
                            child: RoleButton(
                              label: r.$1,
                              asset: r.$2,
                              selected: _role == i,
                              onTap: () => setState(() => _role = i),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
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
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
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
                opacity: _phoneValid ? 1 : 0.6,
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
