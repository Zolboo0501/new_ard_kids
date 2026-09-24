import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'app_input.dart';
import 'app_text.dart';
import 'register_letter_sheet.dart';
import 'ui.dart';

/// A Mongolian register number (`УБ12345678`): two letter boxes that open
/// the [RegisterLetterSheet], then an 8-digit field.
class RegisterNumberField extends StatelessWidget {
  const RegisterNumberField({
    super.key,
    required this.letters,
    required this.onLettersChanged,
    required this.digitsController,
    required this.digitsFocus,
    this.hasError = false,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  static const digitCount = 8;

  /// Hint letters for the empty boxes; with the digit hint they read as the
  /// example `УБ12345678`.
  static const _placeholders = ['У', 'Б'];

  /// Why [letters] and [digits] aren't a full register number yet, or null
  /// when they are. [empty] is the message for a field left untouched.
  static String? validate(
    List<String?> letters,
    String digits, {
    String empty = 'Регистрийн дугаараа оруулна уу.',
  }) {
    if (letters.every((l) => l == null) && digits.isEmpty) return empty;
    if (letters.contains(null)) return 'Регистрийн 2 үсгээ сонгоно уу.';
    if (digits.length != digitCount) {
      return 'Регистрийн $digitCount оронтой тоог оруулна уу.';
    }
    return null;
  }

  final List<String?> letters;
  final ValueChanged<List<String?>> onLettersChanged;
  final TextEditingController digitsController;
  final FocusNode digitsFocus;

  /// Marks whichever part is still incomplete: an empty letter box, or the
  /// digit field when it is short.
  final bool hasError;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  Future<void> _openSheet(BuildContext context, int index) async {
    dismissKeyboard();
    final picked = await showRegisterLetterSheet(
      context,
      initial: letters,
      start: index,
    );
    if (picked == null) return;
    onLettersChanged(picked);
    // Letters done, so carry on to the digits.
    if (digitsController.text.length < digitCount) digitsFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final digitsValid = digitsController.text.length == digitCount;
    // IntrinsicHeight lets the letter boxes stretch to the digit field's
    // height, so the three pieces line up.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < letters.length; i++) ...[
            _LetterBox(
              letter: letters[i],
              placeholder: _placeholders[i],
              hasError: hasError && letters[i] == null,
              semanticLabel: 'Регистрийн ${i + 1}-р үсэг',
              onTap: () => _openSheet(context, i),
            ),
            const SizedBox(width: 6),
          ],
          const SizedBox(width: 2),
          Expanded(
            child: AppInputShell(
              hasError: hasError && !digitsValid,
              valid: digitsValid,
              trailing: AppFieldTick(
                visible: digitsValid && !letters.contains(null),
              ),
              child: TextField(
                controller: digitsController,
                onTapOutside: dismissKeyboard,
                focusNode: digitsFocus,
                keyboardType: TextInputType.number,
                textInputAction: textInputAction,
                onSubmitted: onSubmitted,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(digitCount),
                ],
                style: appInputStyle(letterSpacing: 0.8),
                decoration: appInputDecoration('12345678'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One of the two letter boxes; shows the picked letter or a placeholder.
class _LetterBox extends StatelessWidget {
  const _LetterBox({
    required this.letter,
    required this.placeholder,
    required this.hasError,
    required this.semanticLabel,
    required this.onTap,
  });

  final String? letter;
  final String placeholder;
  final bool hasError;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final filled = letter != null;
    return Semantics(
      button: true,
      label: semanticLabel,
      value: letter,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? Colors.white : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? AppColors.rose400
                  : filled
                  ? AppColors.sky400
                  : AppColors.slate200,
            ),
          ),
          child: filled
              ? AppText(
                  letter!,
                  size: 18,
                  weight: FontWeight.w800,
                  color: AppColors.slate800,
                )
              // A hint, like a text field's, so screen readers skip it.
              : ExcludeSemantics(
                  child: AppText(
                    placeholder,
                    size: 18,
                    weight: FontWeight.w700,
                    color: AppColors.slate300,
                  ),
                ),
        ),
      ),
    );
  }
}
