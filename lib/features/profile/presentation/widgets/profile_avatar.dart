import 'package:flutter/material.dart';

import '../../../../app/avatar.dart';
import '../../../../theme/app_theme.dart';

/// The teen's profile picture: the companion they picked, in a thin accent
/// ring.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.sky500,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.slate50,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.card, width: 2),
        ),
        // Follows the companion picked in "Аватар сонгох".
        child: ValueListenableBuilder(
          valueListenable: appAvatar,
          builder: (context, avatar, _) => ClipOval(
            child: Image.asset(
              avatar.portrait,
              fit: BoxFit.cover,
              semanticLabel: 'Профайл зураг',
            ),
          ),
        ),
      ),
    );
  }
}
