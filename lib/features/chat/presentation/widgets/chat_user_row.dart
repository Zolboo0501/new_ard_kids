import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/chat_thread.dart';
import 'chat_avatar.dart';

/// A person on "Шинэ мессеж": avatar, name and @username; a tap opens the
/// conversation with them.
class ChatUserRow extends StatelessWidget {
  const ChatUserRow({super.key, required this.user, required this.onTap});

  final ChatUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${user.name}, ${user.handle}',
      excludeSemantics: true,
      child: Pressable(
        onTap: withHaptic(onTap),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              ChatAvatar(user: user, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      user.name,
                      size: 15,
                      weight: FontWeight.w600,
                      color: AppColors.slate900,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      user.handle,
                      size: 13,
                      color: AppColors.slate500,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
