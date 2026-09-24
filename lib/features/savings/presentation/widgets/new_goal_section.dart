import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class NewGoalSection extends StatelessWidget {
  const NewGoalSection({
    super.key,
    required this.dot,
    required this.title,
    required this.children,
    this.trailing,
    this.trailingWidget,
  });

  final Color dot;
  final String title;
  final String? trailing;
  final Widget? trailingWidget;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 24,
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.slate100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: AppText(
                  title.toUpperCase(),
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.slate700,
                  letterSpacing: 0.4,
                ),
              ),
              if (trailingWidget != null)
                trailingWidget!
              else if (trailing != null)
                AppText(
                  trailing!,
                  size: 11,
                  weight: FontWeight.w600,
                  color: AppColors.slate400,
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
