import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/ui.dart';

/// The large buttons under Home's balance: what the kid can do with the
/// account in the centre of the carousel.
class HomeAccountActions extends StatelessWidget {
  const HomeAccountActions({super.key, required this.actions});

  /// The buttons as (label, sticker, onTap), sharing the width; the first
  /// is the primary one.
  final List<(String, String, VoidCallback)> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, (label, sticker, onTap)) in actions.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              label: label,
              mascot: sticker,
              primary: i == 0,
              onTap: onTap,
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.mascot,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final String mascot;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.96,
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            color: primary ? AppColors.sky500 : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: primary ? null : Border.all(color: AppColors.sky100),
            boxShadow: [
              BoxShadow(
                color: AppColors.sky500.withValues(alpha: primary ? 0.3 : 0.08),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primary ? Colors.white : AppColors.sky50,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(3),
                child: MascotImage(
                  asset: mascot,
                  size: 30,
                  background: primary ? Colors.white : AppColors.sky50,
                  semanticLabel: '',
                ),
              ),
              const SizedBox(height: 7),
              AppText(
                label,
                size: 13,
                weight: FontWeight.w700,
                color: primary ? Colors.white : AppColors.slate700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
