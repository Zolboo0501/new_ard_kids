import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';

/// The friend's username. Highlights sky while focused, rose when the last
/// send failed validation.
class UsernameField extends StatefulWidget {
  const UsernameField({
    super.key,
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
  State<UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends State<UsernameField> {
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
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.hasError
                ? AppColors.rose400
                : _focused
                ? AppColors.sky500
                : Colors.transparent,
            width: _focused || widget.hasError ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.alternate_email_rounded, size: 18, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: widget.controller,
                onTapOutside: dismissKeyboard,
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
                style: inter(
                  size: 16,
                  weight: FontWeight.w700,
                  color: Night.text,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintText: 'temuulen_07',
                  hintStyle: inter(size: 16, color: AppColors.slate400),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
