import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../data/chat_thread.dart';

/// A chat person's profile picture: the portrait of the avatar they picked
/// in Ard KIDS (on a raised round tile, like the teen's own in the Home
/// header), with a green dot on its lower-right edge while they're active.
class ChatAvatar extends StatelessWidget {
  const ChatAvatar({
    super.key,
    required this.user,
    this.size = 56,
    this.showActive = true,
  });

  final ChatUser user;
  final double size;
  final bool showActive;

  @override
  Widget build(BuildContext context) {
    final dot = (size * 0.28).clamp(10.0, 18.0);
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.slate50,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                user.avatar.portrait,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
            if (showActive && user.active)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: dot,
                  height: dot,
                  decoration: BoxDecoration(
                    color: AppColors.emerald500,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
