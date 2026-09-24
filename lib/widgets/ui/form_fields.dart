/// Form fields: labels, text input and switches.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../app_text.dart';
import 'interaction.dart';

/// Small uppercase-ish field label.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text,
              size: 12,
              weight: FontWeight.w700,
              color: AppColors.slate500,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Rounded input box matching the Stitch forms.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.prefixText,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.textStyle,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? hint;
  final IconData? prefixIcon;
  final String? prefixText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextStyle? textStyle;
  final bool enabled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    // The whole box (prefix, suffix such as the clear button) counts as
    // part of the field, so tapping it doesn't close the keyboard.
    return TextFieldTapRegion(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        constraints: const BoxConstraints(minHeight: 52),
        decoration: BoxDecoration(
          color: widget.enabled ? Colors.white : AppColors.slate50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: focused ? AppColors.sky400 : AppColors.slate200,
            width: focused ? 1.6 : 1,
          ),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: AppColors.sky400.withValues(alpha: 0.15),
                    blurRadius: 0,
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            if (widget.prefixIcon != null) ...[
              Icon(
                widget.prefixIcon,
                size: 20,
                color: focused ? AppColors.sky500 : AppColors.slate400,
              ),
              const SizedBox(width: 10),
            ],
            if (widget.prefixText != null) ...[
              AppText(
                widget.prefixText!,
                size: 18,
                weight: FontWeight.w700,
                color: AppColors.slate500,
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                onTapOutside: dismissKeyboard,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                onTap: widget.onTap,
                onChanged: widget.onChanged,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                maxLines: widget.maxLines,
                cursorColor: AppColors.sky500,
                style:
                    widget.textStyle ??
                    inter(size: 14, weight: FontWeight.w700),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  hintText: widget.hint,
                  hintStyle: inter(size: 14, color: AppColors.slate400),
                ),
              ),
            ),
            if (widget.suffix != null) ...[
              const SizedBox(width: 8),
              widget.suffix!,
            ],
          ],
        ),
      ),
    );
  }
}

/// On/off switch styled for the app.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return Switch.adaptive(
      value: value,
      onChanged: onChanged == null
          ? null
          : (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
      activeTrackColor: AppColors.sky500,
      activeThumbColor: Colors.white,
      inactiveTrackColor: AppColors.slate200,
      inactiveThumbColor: Colors.white,
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }
}
