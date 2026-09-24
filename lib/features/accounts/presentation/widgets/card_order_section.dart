import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class CardOrderSection extends StatelessWidget {
  const CardOrderSection({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final Widget? trailing;
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
              Expanded(
                child: AppText(
                  title,
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              ?trailing,
            ],
          ),
          const Divider(height: 22, color: AppColors.slate100),
          ...children,
        ],
      ),
    );
  }
}
