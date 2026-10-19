import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/chat_thread.dart';
import 'chat_avatar.dart';

/// One conversation in the inbox, flat like a DM list: the avatar (with
/// the active dot), the name, the last message and how long ago, and a dot
/// in the accent while there's something unread.
class ChatThreadRow extends StatelessWidget {
  const ChatThreadRow({super.key, required this.thread, required this.onTap});

  final ChatThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final last = thread.last;
    final unread = thread.unread > 0;
    final preview = switch (last) {
      null => 'Шинэ чат',
      _ when unread && thread.unread > 1 => '${thread.unread} шинэ мессеж',
      ChatMessage(mine: true, :final text) => 'Та: $text',
      ChatMessage(:final text) => text,
    };
    final ago = last == null
        ? null
        : chatAgo(DateTime.now().difference(last.at));
    return Semantics(
      button: true,
      label: '${thread.name}, $preview${unread ? ', уншаагүй' : ''}',
      excludeSemantics: true,
      child: Pressable(
        onTap: withHaptic(onTap),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              ChatAvatar(user: thread.user),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      thread.name,
                      size: 15,
                      weight: unread ? FontWeight.w700 : FontWeight.w500,
                      color: AppColors.slate900,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Flexible(
                          child: AppText(
                            preview,
                            size: 13,
                            weight: unread ? FontWeight.w600 : FontWeight.w400,
                            color: unread
                                ? AppColors.slate900
                                : AppColors.slate500,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (ago != null)
                          AppText(
                            ' · $ago',
                            size: 13,
                            color: AppColors.slate500,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Keeps its width when read, so the text column doesn't move.
              SizedBox(
                width: 10,
                child: unread
                    ? Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.sky500,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
