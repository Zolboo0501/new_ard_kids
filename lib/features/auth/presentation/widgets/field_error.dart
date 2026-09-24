import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/value_switcher.dart';

/// Validation message under the field. Collapses to nothing when [message] is
/// null so the card does not reserve empty space.
class FieldError extends StatelessWidget {
  const FieldError({super.key, required this.message});

  final String? message;

  static const _duration = Duration(milliseconds: 240);

  @override
  Widget build(BuildContext context) {
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
