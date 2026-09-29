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
        behavior: HitTestBehavior.opaque,
        onTap: withHaptic(onTap),
        // A 24pt dot in a 44pt hit area.
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.slate200,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: LineIcon(
              LineGlyph.close,
              size: 14,
              stroke: 2,
              color: AppColors.slate600,
            ),
          ),
        ),
      ),
    );
  }
}
