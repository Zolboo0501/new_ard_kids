import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/chat_thread.dart';
import '../widgets/chat_avatar.dart';
import '../widgets/chat_thread_row.dart';

/// "Чат": the Чат tab of the signed-in shell, a DM inbox with other Ard KIDS
/// users (chat stays inside the app): a search pill, the friends who are
/// active right now, then every conversation. A row opens [AppRoutes.chatThread] over the bar; the search pill and the
/// header's button open [AppRoutes.newChat] to find someone by username.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _openUser(ChatUser user) =>
      _push(AppRoutes.chatThreadOf(chatThreadWith(user).id));

  Future<void> _push(String route) async {
    await context.push(route);
    // Opening a thread reads it, so its unread count is gone on return.
    // (Started threads and new messages arrive through
    // [chatThreadsChanged].)
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: chatThreadsChanged,
    builder: (context, _, _) => _build(context),
  );

  Widget _build(BuildContext context) {
    final bg = AppColors.surface;
    final active = mockChatUsers.where((u) => u.active).toList();
    return ColoredBox(
      color: bg,
      child: Column(
        children: [
          SubPageHeader(
            title: 'Чат',
            background: bg,
            showBack: false,
            trailing: CircleIconButton(
              icon: Iconsax.edit_copy,
              label: 'Шинэ чат',
              onPressed: () => _push(AppRoutes.newChat),
            ),
          ),
          Expanded(
            child: EntranceScope(
              child: AdaptiveListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  AppLayout.navClearance(context),
                ),
                children: EntranceItem.list([
                  _SearchPill(onTap: () => _push(AppRoutes.newChat)),
                  const SizedBox(height: 16),
                  if (active.isNotEmpty) ...[
                    SizedBox(
                      height: 92,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: active.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 16),
                        itemBuilder: (context, i) => _ActiveFriend(
                          user: active[i],
                          onTap: () => _openUser(active[i]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  AppText(
                    'Мессежүүд',
                    size: 16,
                    weight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                  const SizedBox(height: 6),
                  for (final t in mockChatThreads)
                    ChatThreadRow(
                      thread: t,
                      onTap: () => _push(AppRoutes.chatThreadOf(t.id)),
                    ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Looks like a search field; opens the username search.
class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Хайх',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: withHaptic(onTap),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.slate100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              LineIcon(LineGlyph.search, size: 18, color: AppColors.slate500),
              const SizedBox(width: 8),
              AppText('Хайх', size: 15, color: AppColors.slate500),
            ],
          ),
        ),
      ),
    );
  }
}

/// A friend who's online, in the row above the inbox.
class _ActiveFriend extends StatelessWidget {
  const _ActiveFriend({required this.user, required this.onTap});

  final ChatUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${user.name}, идэвхтэй',
      excludeSemantics: true,
      child: Pressable(
        onTap: withHaptic(onTap),
        child: SizedBox(
          width: 64,
          child: Column(
            children: [
              ChatAvatar(user: user, size: 64),
              const SizedBox(height: 6),
              AppText(
                user.firstName,
                size: 12,
                color: AppColors.slate700,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
