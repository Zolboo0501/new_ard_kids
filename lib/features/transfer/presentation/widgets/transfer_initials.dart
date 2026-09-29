import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';

/// A person's two initials in a circle: contacts, parents, senders.
class TransferInitials extends StatelessWidget {
  const TransferInitials(this.initials, {super.key, this.size = 44});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.slate100,
          shape: BoxShape.circle,
        ),
        child: AppText(
          initials,
          size: size * 0.32,
          weight: FontWeight.w600,
          color: AppColors.slate800,
        ),
      ),
    );
  }
}
