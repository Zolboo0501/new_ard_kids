import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_input.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../../auth/presentation/widgets/header.dart';
import '../widgets/parent_link_highlight.dart';
import '../widgets/role_button.dart';
import '../widgets/success_sheet.dart';

/// "Эцэг эхийн холболт": send a link request to a parent/guardian.
///
/// Opened from Home or Profile; it is no longer a registration step, so the
/// header carries neither a step pill nor a skip button.
class ParentLinkScreen extends StatefulWidget {
  const ParentLinkScreen({super.key});

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
    if (mounted) context.go(AppRoutes.home);
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
              const Header(),
              const SizedBox(height: 12),
              AppText(
                'Эцэг эхтэйгээ холбох',
                size: 28,
                weight: FontWeight.w700,
                color: AppColors.slate900,
                height: 1.2,
                letterSpacing: -0.6,
              ),
              const SizedBox(height: 20),
              ParentLinkHighlight(dad: _role == 1),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
            ]),
          ),
        ),
      ),
    );
  }
}
