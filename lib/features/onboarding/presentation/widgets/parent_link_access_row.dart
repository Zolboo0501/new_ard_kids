import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One line of what a linked parent can or can't see, on [ParentLinkScreen].
class ParentLinkAccessRow extends StatelessWidget {
  const ParentLinkAccessRow({
    super.key,
    required this.text,
    required this.visible,
  });

  final String text;

  /// Whether the parent sees this; drawn as a tick or a crossed-out eye.
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LineIcon(
            visible ? LineGlyph.check : LineGlyph.eyeOff,
            size: 18,
            color: visible ? AppColors.emerald600 : AppColors.slate500,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              text,
              size: 14,
              color: AppColors.slate800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
