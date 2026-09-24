import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';

class TransferLabel extends StatelessWidget {
  const TransferLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: AppText(
        text,
        size: 12,
        weight: FontWeight.w700,
        color: AppColors.slate700,
      ),
    );
  }
}
