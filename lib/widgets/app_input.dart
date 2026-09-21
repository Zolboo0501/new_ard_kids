import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_text.dart';
import 'value_switcher.dart';

/// The label sitting above an [AppInputShell].
class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AppText(
        text,
        size: 12,
        weight: FontWeight.w700,
        color: AppColors.slate600,
      ),
    );
  }
}

/// Rounded input container with a white badge on the left; highlights with a
/// sky border and halo while the inner field has focus, rose when [hasError].
///
/// Shakes once each time it newly becomes invalid, so a failed submit draws
/// the eye to the field that needs fixing.
class AppInputShell extends StatefulWidget {
  const AppInputShell({
    super.key,
    required this.leading,
    required this.child,
    this.trailing,
    this.hasError = false,
  });

  final Widget leading;
  final Widget child;
  final Widget? trailing;

  /// Paints the border and halo red instead of sky, and triggers the shake.
  final bool hasError;

  @override
  State<AppInputShell> createState() => _AppInputShellState();
}

class _AppInputShellState extends State<AppInputShell>
    with SingleTickerProviderStateMixin {
  bool _focused = false;

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(AppInputShell old) {
    super.didUpdateWidget(old);
    // Only on the transition into an error, so re-submitting with the same
    // mistake still nudges but typing does not.
    if (!old.hasError &&
        widget.hasError &&
        !MediaQuery.disableAnimationsOf(context)) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shake,
      // Leading/trailing parts count as the field, so tapping them doesn't
      // close the keyboard (see `dismissKeyboard`).
      child: TextFieldTapRegion(child: _buildShell()),
      builder: (context, child) {
        if (_shake.isDismissed) return child!;
        // Three decaying swings either side of centre.
        final decay = 1 - _shake.value;
        final dx = math.sin(_shake.value * math.pi * 6) * 6 * decay;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }

  Widget _buildShell() {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _focused ? Colors.white : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.hasError
                ? AppColors.rose400
                : _focused
                ? AppColors.sky400
                : AppColors.slate200,
          ),
          boxShadow: widget.hasError || _focused
              ? [
                  BoxShadow(
                    color:
                        (widget.hasError ? AppColors.rose400 : AppColors.sky400)
                            .withValues(alpha: 0.4),
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: widget.leading,
            ),
            const SizedBox(width: 8),
            Expanded(child: widget.child),
            ?widget.trailing,
          ],
        ),
      ),
    );
  }
}

/// Validation message under a field. Collapses to nothing when [message] is
/// null so the form doesn't reserve empty space.
class AppFieldError extends StatelessWidget {
  const AppFieldError({super.key, required this.message});

  final String? message;

  static const _duration = Duration(milliseconds: 240);

  @override
  Widget build(BuildContext context) {
    // AnimatedSize opens the gap; AnimatedSwitcher fades and drops the message
    // into it, so the text arrives with the space instead of popping in.
    return AnimatedSize(
      duration: _duration,
      curve: appEmphasizedDecelerate,
      alignment: Alignment.topCenter,
      child: ValueSwitcher(
        value: message,
        duration: _duration,
        switchInCurve: appEmphasizedDecelerate,
        switchOutCurve: appEmphasizedAccelerate,
        transitionBuilder: (child, animation, _) => FadeTransition(
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
                padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
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

/// The green tick that fades in once a field's value is valid.
class AppFieldTick extends StatelessWidget {
  const AppFieldTick({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 150),
      child: const SizedBox(
        width: 32,
        height: 32,
        child: Icon(
          Icons.check_circle_rounded,
          size: 20,
          color: AppColors.emerald500,
        ),
      ),
    );
  }
}

/// The Comfortaa style the fields inside an [AppInputShell] use.
TextStyle appInputStyle({double letterSpacing = 0}) =>
    comfortaa(size: 14, weight: FontWeight.w700, letterSpacing: letterSpacing);

/// Borderless decoration for a field inside an [AppInputShell].
InputDecoration appInputDecoration(String hint) => InputDecoration(
  isDense: true,
  border: InputBorder.none,
  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
  hintText: hint,
  hintStyle: comfortaa(size: 14, color: AppColors.slate300),
);
