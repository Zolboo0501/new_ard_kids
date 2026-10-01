import 'package:flutter/material.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/common.dart';
import '../../../../widgets/app_text.dart';

class Header extends StatelessWidget {
  const Header({super.key, this.step, this.trailing});

  /// Registration progress, omitted when editing an existing profile.
  final String? step;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final progressColor = Theme.of(context).colorScheme.primary;
    final match = RegExp(r'(\d+)/(\d+)').firstMatch(step ?? '');
    final current = match == null ? 0 : int.parse(match.group(1)!);
    final total = match == null ? 0 : int.parse(match.group(2)!);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              const CircleBackButton(),
              const SizedBox(width: 12),
              Expanded(
                child: step == null
                    ? const SizedBox.shrink()
                    : AppText(
                        step!,
                        size: 13,
                        weight: FontWeight.w600,
                        color: AppColors.slate600,
                      ),
              ),
              ?trailing,
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 16),
            Semantics(
              label: 'Бүртгэлийн явц',
              value: '$total алхмын $current',
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    for (var i = 0; i < total; i++) ...[
                      if (i > 0) const SizedBox(width: 5),
                      Expanded(
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: i < current
                                ? progressColor
                                : progressColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
