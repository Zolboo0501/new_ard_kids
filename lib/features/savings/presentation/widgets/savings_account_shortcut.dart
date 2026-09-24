import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/ui.dart';

class SavingsAccountShortcut extends StatelessWidget {
  const SavingsAccountShortcut({
    super.key,
    required this.label,
    required this.asset,
    required this.onTap,
  });

  final String label;
  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        radius: 20,
        padding: const EdgeInsets.symmetric(vertical: 12),
        borderColor: AppColors.slate100,
        onTap: onTap,
        child: Column(
          children: [
            MascotImage(
              asset: asset,
              size: 56,
              background: Colors.white,
              semanticLabel: label,
            ),
            const SizedBox(height: 4),
            AppText(label, size: 12, weight: FontWeight.w700),
          ],
        ),
      ),
    );
  }
}
