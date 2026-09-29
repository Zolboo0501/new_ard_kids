import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One card of the new-goal form: a title, an optional trailing note or
/// widget, then the section's fields.
class NewGoalSection extends StatelessWidget {
  const NewGoalSection({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
    this.trailingWidget,
  });

  final String title;
  final String? trailing;
  final Widget? trailingWidget;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  title,
                  size: 16,
                  weight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              if (trailingWidget != null)
                trailingWidget!
              else if (trailing != null)
                AppText(trailing!, size: 13, color: AppColors.slate500),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
