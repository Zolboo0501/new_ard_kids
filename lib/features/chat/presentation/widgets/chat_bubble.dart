import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../data/chat_emoji.dart';
import '../../data/chat_stickers.dart';
import '../../data/chat_thread.dart';
import 'chat_avatar.dart';
import 'chat_reaction_bar.dart';

/// One message, DM style: the teen's own on the right in the theme's
/// accent (flat), the other person's on the left in grey with their avatar
/// beside the last of a run; a sticker or a heart stands on its own, with no
/// bubble. Messages in a run ([first]/[last]) share tighter corners on the
/// sender's side. Long-press opens the reactions ([showChatReactionBar]);
/// double-tap puts a heart on it, or takes it off. The reaction sits on the
/// bubble's lower corner.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.user,
    required this.first,
    required this.last,
    required this.onReact,
  });

  final ChatMessage message;

  /// The other person, whose avatar sits beside their run.
  final ChatUser user;
  final bool first;
  final bool last;

  /// Called with the new reaction, or null when it's taken off.
  final ValueChanged<String?> onReact;

  static const _round = Radius.circular(20);
  static const _joined = Radius.circular(5);
  static const _avatar = 28.0;

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    final reaction = message.reaction;
    final reacted = reaction != null;
    final sticker = message.sticker;
    final body = sticker != null
        ? (message.emoji ? _emojiArt(sticker) : _sticker(sticker))
        : message.heart
        ? _heart()
        : _bigEmoji(message.text) ?? _bubble(context, mine);

    final reactable = Builder(
      builder: (context) => GestureDetector(
        onDoubleTap: () {
          HapticFeedback.lightImpact();
          final heart = chatReactions.first;
          onReact(reaction == heart ? null : heart);
        },
        onLongPress: () => _pickReaction(context),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: reacted ? 16 : 0),
              child: body,
            ),
            if (reacted)
              Positioned(
                bottom: 0,
                left: mine ? null : 10,
                right: mine ? 10 : null,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: Image.asset(
                    reaction,
                    width: 18,
                    height: 18,
                    filterQuality: FilterQuality.high,
                    semanticLabel: chatEmojiLabel(reaction),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: last ? 10 : 2),
      child: Row(
        mainAxisAlignment: mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            SizedBox(
              width: _avatar,
              child: last
                  ? Padding(
                      padding: EdgeInsets.only(bottom: reacted ? 16 : 0),
                      child: ChatAvatar(
                        user: user,
                        size: _avatar,
                        showActive: false,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: FractionallySizedBox(
              alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
              widthFactor: 0.82,
              child: Align(
                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                child: reactable,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReaction(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final current = message.reaction;
    final picked = await showChatReactionBar(
      context,
      target: context.findRenderObject()! as RenderBox,
      alignEnd: message.mine,
      current: current,
    );
    if (picked == null) return;
    onReact(picked == current ? null : picked);
  }

  Widget _sticker(String path) => Image.asset(
    path,
    width: 120,
    height: 120,
    filterQuality: FilterQuality.high,
    semanticLabel: chatStickerLabel(path),
  );

  /// One of the app's 3D emoji: the size of a large Unicode one.
  Widget _emojiArt(String path) => Image.asset(
    path,
    width: 64,
    height: 64,
    filterQuality: FilterQuality.high,
    semanticLabel: chatEmojiLabel(path),
  );

  /// One to three emoji on their own are drawn large with no bubble;
  /// anything else (more emoji, or any text) stays in the bubble.
  Widget? _bigEmoji(String text) {
    if (!isEmojiOnly(text)) return null;
    final emoji = text.replaceAll(RegExp(r'\s'), '').characters.length;
    if (emoji > 3) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: AppText(text.trim(), size: emoji == 1 ? 48 : 40, height: 1.2),
    );
  }

  /// A heart sent from the composer: the ❤️ emoji, the size of a large
  /// Unicode one.
  Widget _heart() => Image.asset(
    chatReactions.first,
    width: 56,
    height: 56,
    filterQuality: FilterQuality.high,
    semanticLabel: 'Зүрх',
  );

  Widget _bubble(BuildContext context, bool mine) {
    // The sender's side joins the bubbles above and below in a run.
    final top = first ? _round : _joined;
    final bottom = last ? _round : _joined;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        // The accent picked in Харагдац, flat.
        color: mine ? AppColors.sky500 : AppColors.slate100,
        borderRadius: BorderRadius.only(
          topLeft: mine ? _round : top,
          bottomLeft: mine ? _round : bottom,
          topRight: mine ? top : _round,
          bottomRight: mine ? bottom : _round,
        ),
      ),
      child: AppText(
        message.text,
        size: 15,
        height: 1.3,
        color: mine ? AppColors.onAccent : AppColors.slate900,
      ),
    );
  }
}
