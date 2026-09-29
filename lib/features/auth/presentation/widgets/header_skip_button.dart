import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// "Алгасах" on the right of the onboarding [Header]: a plain text action
/// with a full 44pt target.
class HeaderSkipButton extends StatelessWidget {
  const HeaderSkipButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: withHaptic(onPressed),
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: AppText(
        'Алгасах',
        size: 14,
        weight: FontWeight.w600,
        color: AppColors.slate600,
      ),
    );
  }
}
