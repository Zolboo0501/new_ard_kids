import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/kid_profile.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_input.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../../auth/presentation/widgets/header.dart';
import '../../../auth/presentation/widgets/header_skip_button.dart';
import '../widgets/parent_link_access_row.dart';
import '../widgets/parent_link_limit_row.dart';
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

  /// The choice and the possessive form used in the phone field's label.
  static const _roles = [('Ээж', 'Ээжийн'), ('Аав', 'Аавын')];

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
    final roleLabel = _roles[_role].$2;
    return Scaffold(
      backgroundColor: AppColors.surface,
      // No appBar: the shared onboarding Header scrolls with the content, the
      // way it does on the other steps.
      body: SafeArea(
        bottom: false,
        child: EntranceScope(
          child: AdaptiveListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: EntranceItem.list([
              Header(
                step: widget.onboarding ? 'Алхам 6/6' : null,
                trailing: HeaderSkipButton(
                  onPressed: () => _goHome(linked: false),
                ),
              ),
              const SizedBox(height: 12),
              AppText(
                'Эцэг эхтэйгээ холбох',
                size: 28,
                weight: FontWeight.w700,
                color: AppColors.slate900,
                height: 1.2,
                letterSpacing: -0.6,
              ),
              const SizedBox(height: 8),
              AppText(
                'Холбосны дараа өдрийн гүйлгээний эрх '
                '${formatMnt(Limits.unlinkedDaily)}-с '
                '${formatMnt(Limits.dailyTransfer)} болно.',
                size: 15,
                color: AppColors.slate500,
                height: 1.45,
              ),
              const SizedBox(height: 24),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppFieldLabel('Хэнтэй холбох вэ'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final (i, r) in _roles.indexed) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: RoleButton(
                              label: r.$1,
                              selected: _role == i,
                              onTap: () => setState(() => _role = i),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppFieldLabel('$roleLabel утасны дугаар'),
                    const SizedBox(height: 6),
                    AppInputShell(
                      hasError: _phoneError != null,
                      leading: AppText(
                        '+976',
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColors.slate600,
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Always tappable: pressing it with a bad field is how the user
              // finds out what is wrong, so gating it would hide the message.
              // Until the phone is valid it wears the flat "not ready" colours
              // instead of fading, which reads as mud on the dark canvas.
              PrimaryButton(
                label: 'Эцэг эх рүү хүсэлт илгээх',
                height: 56,
                color: _phoneValid ? null : AppColors.slate100,
                foreground: _phoneValid ? null : AppColors.slate500,
                onPressed: _submit,
              ),
              const SizedBox(height: 10),
              AppText(
                'Хүсэлт эцэг эхийн апп руу очно. Зөвшөөрмөгц эрх шууд нэмэгдэнэ.',
                size: 13,
                color: AppColors.slate500,
                height: 1.4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const AppText(
                'Эрх хэрхэн өөрчлөгдөх вэ',
                size: 16,
                weight: FontWeight.w700,
              ),
              const SizedBox(height: 4),
              ParentLinkLimitRow(
                label: 'Өдрийн гүйлгээний эрх',
                before: formatMnt(Limits.unlinkedDaily),
                after: formatMnt(Limits.dailyTransfer),
              ),
              Divider(height: 1, thickness: 1, color: AppColors.line),
              const ParentLinkLimitRow(
                label: 'Өдрийн гүйлгээний тоо',
                before: '2 удаа',
                after: 'Хязгааргүй',
              ),
              const SizedBox(height: 28),
              const AppText(
                'Эцэг эх чинь юу харах вэ',
                size: 16,
                weight: FontWeight.w700,
              ),
              const SizedBox(height: 8),
              const ParentLinkAccessRow(
                text: 'Дансны үлдэгдэл, гүйлгээний түүх',
                visible: true,
              ),
              const ParentLinkAccessRow(
                text: 'Чиний мөнгөний хүсэлтийг зөвшөөрөх, татгалзах',
                visible: true,
              ),
              const ParentLinkAccessRow(
                text: 'Нууц код, нэвтрэх мэдээлэл чинь харагдахгүй',
                visible: false,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
