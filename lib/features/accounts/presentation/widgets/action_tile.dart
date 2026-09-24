import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: AppCard(
        onTap: withHaptic(onTap),
        radius: 18,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        color: highlighted ? AppColors.sky500 : Colors.white,
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: highlighted
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.sky50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18,
                color: highlighted ? Colors.white : AppColors.sky600,
              ),
            ),
            const SizedBox(height: 6),
            AppText(
              label,
              size: 11,
              weight: FontWeight.w700,
              color: highlighted ? Colors.white : AppColors.slate700,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
