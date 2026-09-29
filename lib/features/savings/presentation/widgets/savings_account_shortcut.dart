import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One of the savings account's action buttons: a line icon over a label.
class SavingsAccountShortcut extends StatelessWidget {
  const SavingsAccountShortcut({
    super.key,
    required this.label,
    required this.glyph,
    required this.onTap,
  });

  final String label;
  final LineGlyph glyph;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          onTap: onTap,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.sky50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: LineIcon(glyph, size: 20, color: AppColors.sky600),
              ),
              const SizedBox(height: 8),
              AppText(
                label,
                size: 13,
                weight: FontWeight.w600,
                color: AppColors.slate800,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
