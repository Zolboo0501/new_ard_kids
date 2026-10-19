import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/chat_thread.dart';
import 'chat_avatar.dart';

/// One message, DM style: the teen's own on the right in an accent
/// gradient, the other person's on the left in grey with their avatar
/// beside the last of a run. Messages in a run ([first]/[last]) share
/// tighter corners on the sender's side. Double-tap likes it.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.user,
    required this.first,
    required this.last,
    required this.onLike,
  });

  final ChatMessage message;

  /// The other person, whose avatar sits beside their run.
  final ChatUser user;
  final bool first;
  final bool last;
  final VoidCallback onLike;

  static const _round = Radius.circular(20);
  static const _joined = Radius.circular(5);
  static const _avatar = 28.0;

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    final liked = message.liked;
    final body = message.heart ? _heart() : _bubble(context, mine);

    final likeable = GestureDetector(
      onDoubleTap: () {
        HapticFeedback.lightImpact();
        onLike();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: liked ? 14 : 0),
            child: body,
          ),
          if (liked)
            Positioned(
              bottom: 0,
              left: mine ? null : 10,
              right: mine ? 10 : null,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                child: LineIcon(
                  LineGlyph.heart,
                  size: 12,
                  color: AppColors.rose500,
                  semanticLabel: 'Таалагдсан',
                ),
              ),
            ),
        ],
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
                      padding: EdgeInsets.only(bottom: liked ? 14 : 0),
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
                child: likeable,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heart() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    child: LineIcon(
      LineGlyph.heart,
      size: 44,
      color: AppColors.rose500,
      semanticLabel: 'Зүрх',
    ),
  );

  Widget _bubble(BuildContext context, bool mine) {
    // The sender's side joins the bubbles above and below in a run.
    final top = first ? _round : _joined;
    final bottom = last ? _round : _joined;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: mine ? null : AppColors.slate100,
        gradient: mine
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.sky400, AppColors.sky600],
              )
            : null,
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
