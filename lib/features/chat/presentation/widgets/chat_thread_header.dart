import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../data/chat_thread.dart';
import 'chat_avatar.dart';

/// A conversation's app bar, DM style: back, the person's avatar with the
/// active dot, their name and whether they're active.
class ChatThreadHeader extends StatelessWidget implements PreferredSizeWidget {
  const ChatThreadHeader({super.key, required this.user});

  final ChatUser user;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const CircleBackButton(),
              const SizedBox(width: 10),
              ChatAvatar(user: user, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      user.name,
                      size: 16,
                      weight: FontWeight.w700,
                      color: AppColors.slate900,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppText(
                      user.status,
                      size: 12,
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
