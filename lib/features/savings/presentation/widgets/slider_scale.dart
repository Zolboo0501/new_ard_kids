import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';

class SliderScale extends StatelessWidget {
  const SliderScale({super.key, required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final l in labels)
            AppText(
              l,
              size: 10,
              weight: FontWeight.w600,
              color: AppColors.slate400,
            ),
        ],
      ),
    );
  }
}
