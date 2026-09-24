import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';

class ClearButton extends StatelessWidget {
  const ClearButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Арилгах',
      child: GestureDetector(
        onTap: withHaptic(onTap),
        child: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.slate200,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 14,
            color: AppColors.slate500,
          ),
        ),
      ),
    );
  }
}
