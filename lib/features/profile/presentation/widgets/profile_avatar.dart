import 'package:flutter/material.dart';

import '../../../../app/avatar.dart';
import '../../../../theme/app_theme.dart';

/// Round gradient-ringed avatar used on the profile screens.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.size = 80, this.badge});

  final double size;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [AppColors.sky400, AppColors.emerald300],
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(2),
            // Follows the companion picked in "Аватар сонгох".
            child: ValueListenableBuilder(
              valueListenable: appAvatar,
              builder: (context, avatar, _) => ClipOval(
                child: Image.asset(
                  avatar.portrait,
                  fit: BoxFit.cover,
                  semanticLabel: 'Хүүхдийн профайл зураг',
                ),
              ),
            ),
          ),
        ),
        if (badge != null) Positioned(right: -2, bottom: -2, child: badge!),
      ],
    );
  }
}
