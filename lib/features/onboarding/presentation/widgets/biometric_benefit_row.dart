import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One reason to turn on biometric sign-in, on [BiometricSetupScreen].
class BiometricBenefitRow extends StatelessWidget {
  const BiometricBenefitRow({
    super.key,
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final BadgeTone tone;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, _) = tone.colors;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 20, color: fg),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(title, size: 13, weight: FontWeight.w700),
              const SizedBox(height: 2),
              AppText(
                subtitle,
                size: 11,
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
