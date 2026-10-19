import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';
import '../../data/chat_emoji.dart';

/// Opens a [ChatReactionBar] over [target] (the message that was held) and
/// resolves the reaction picked, or `null` when it's dismissed.
Future<String?> showChatReactionBar(
  BuildContext context, {
  required RenderBox target,
  required bool alignEnd,
  String? current,
}) {
  final reduce = MediaQuery.disableAnimationsOf(context);
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Хаах',
    barrierColor: Colors.transparent,
    transitionDuration: reduce
        ? Duration.zero
        : const Duration(milliseconds: 200),
    pageBuilder: (context, _, _) =>
        ChatReactionBar(target: target, alignEnd: alignEnd, current: current),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.8, end: 1.0).animate(curved),
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: child,
        ),
      );
    },
  );
}

/// The row of [chatReactions] a long press on a message opens, in a pill
/// above it (below when there's no room), lined up with the bubble's side.
/// The reaction already on the message sits on the accent's tint; picking
/// it again takes it off.
class ChatReactionBar extends StatelessWidget {
  const ChatReactionBar({
    super.key,
    required this.target,
    required this.alignEnd,
    this.current,
  });

  /// The held message, measured where the bar is laid out.
  final RenderBox target;

  /// Whether the bar lines up with the bubble's right edge (the teen's own
  /// messages) rather than its left.
  final bool alignEnd;
  final String? current;

  static const _emoji = 36.0;
  static const _gap = 6.0;
  static const _pad = 8.0;
  static const _height = _emoji + _pad * 2;
  static double get _width =>
      chatReactions.length * _emoji +
      (chatReactions.length - 1) * _gap +
      _pad * 2;

  @override
  Widget build(BuildContext context) {
    final overlay = Overlay.of(context).context.findRenderObject();
    final origin = target.localToGlobal(Offset.zero, ancestor: overlay);
    final anchor = origin & target.size;
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

    final above = anchor.top - _height - 8;
    final top = above >= padding.top + 8 ? above : anchor.bottom + 8;
    final left = (alignEnd ? anchor.right - _width : anchor.left).clamp(
      12.0,
      size.width - _width - 12,
    );

    return Stack(
      children: [
        Positioned(
          top: top,
          left: left,
          child: Material(
            color: AppColors.card,
            elevation: 0,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: _width,
              height: _height,
              padding: const EdgeInsets.all(_pad),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final path in chatReactions)
                    Semantics(
                      button: true,
                      selected: path == current,
                      label: chatEmojiLabel(path),
                      excludeSemantics: true,
                      child: Pressable(
                        key: ValueKey(path),
                        scale: 0.8,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).pop(path);
                        },
                        child: Container(
                          width: _emoji,
                          height: _emoji,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: path == current
                                ? AppColors.sky100
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            path,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
