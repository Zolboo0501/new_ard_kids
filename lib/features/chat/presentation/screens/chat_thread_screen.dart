import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../data/chat_thread.dart';
import '../widgets/chat_avatar.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_thread_header.dart';

/// One conversation, opened from the Чат tab, DM style: the person's card
/// at the top, messages in runs with a stamp after each pause, "Харсан" or
/// "Илгээсэн" under the teen's last message, and the composer.
class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({super.key, this.threadId});

  /// The thread to show; the first one when it's missing or unknown.
  final String? threadId;

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  late final ChatThread _thread =
      chatThreadById(widget.threadId) ?? mockChatThreads.first;

  /// A longer pause than this starts a new stamp.
  static const _stampGap = Duration(hours: 1);

  /// Messages closer than this from the same sender form one run.
  static const _runGap = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _thread.unread = 0;
  }

  void _add(ChatMessage message) {
    // TODO: send the message to the API.
    setState(() {
      _thread.messages.add(message);
      _thread.seen = false;
    });
    chatThreadsChanged.value++;
  }

  void _send(String text) =>
      _add(ChatMessage(text: text, at: DateTime.now(), mine: true));

  void _sendHeart() => _add(ChatMessage.heart(at: DateTime.now(), mine: true));

  /// The conversation top to bottom; the list shows it reversed so it
  /// opens on the newest message.
  List<Widget> _items() {
    final messages = _thread.messages;
    final items = <Widget>[_Intro(user: _thread.user, empty: messages.isEmpty)];
    bool joins(ChatMessage a, ChatMessage b) =>
        a.mine == b.mine && b.at.difference(a.at) < _runGap;
    for (final (i, m) in messages.indexed) {
      final prev = i > 0 ? messages[i - 1] : null;
      final next = i + 1 < messages.length ? messages[i + 1] : null;
      final stamp = prev == null || m.at.difference(prev.at) > _stampGap;
      if (stamp) items.add(_Stamp(chatStamp(m.at)));
      items.add(
        ChatBubble(
          message: m,
          user: _thread.user,
          first: prev == null || !joins(prev, m),
          last: next == null || !joins(m, next),
          onLike: () => setState(() => m.liked = !m.liked),
        ),
      );
    }
    if (_thread.last case ChatMessage(mine: true)) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: AppText(
            _thread.seen ? 'Харсан' : 'Илгээсэн',
            size: 12,
            color: AppColors.slate500,
            textAlign: TextAlign.right,
          ),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _items();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: ChatThreadHeader(user: _thread.user),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: items.length,
              itemBuilder: (context, i) => items[items.length - 1 - i],
            ),
          ),
          ChatComposer(onSend: _send, onHeart: _sendHeart),
        ],
      ),
    );
  }
}

/// The person's card at the very top of a conversation.
class _Intro extends StatelessWidget {
  const _Intro({required this.user, required this.empty});

  final ChatUser user;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 28),
      child: Column(
        children: [
          ChatAvatar(user: user, size: 88, showActive: false),
          const SizedBox(height: 12),
          AppText(
            user.name,
            size: 18,
            weight: FontWeight.w700,
            color: AppColors.slate900,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          AppText(
            '${user.handle} · ${user.relation} · Ard KIDS',
            size: 13,
            color: AppColors.slate500,
            textAlign: TextAlign.center,
          ),
          if (empty) ...[
            const SizedBox(height: 16),
            AppText(
              'Анхны мессежээ бичээрэй.',
              size: 14,
              color: AppColors.slate500,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// The centred time over the messages after a pause.
class _Stamp extends StatelessWidget {
  const _Stamp(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: AppText(
        label,
        size: 12,
        weight: FontWeight.w500,
        color: AppColors.slate400,
        textAlign: TextAlign.center,
      ),
    );
  }
}
