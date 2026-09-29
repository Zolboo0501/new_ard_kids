import 'package:flutter/material.dart';

import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// A titled card on "Миний карт" (details, limits).
class CardSection extends StatelessWidget {
  const CardSection({
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(title, size: 16, weight: FontWeight.w700),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
