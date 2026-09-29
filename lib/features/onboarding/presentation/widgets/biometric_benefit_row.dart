import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One reason to turn on biometric sign-in, on [BiometricSetupScreen].
class BiometricBenefitRow extends StatelessWidget {
  const BiometricBenefitRow({
    super.key,
    required this.glyph,
    required this.title,
    required this.subtitle,
  });

  final LineGlyph glyph;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: LineIcon(glyph, size: 20, color: AppColors.slate800),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                size: 15,
                weight: FontWeight.w600,
                color: AppColors.slate900,
              ),
              const SizedBox(height: 2),
              AppText(
                subtitle,
                size: 13,
                color: AppColors.slate500,
                height: 1.4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
