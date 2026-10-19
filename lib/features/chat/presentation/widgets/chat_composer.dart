import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';
import '../../data/chat_emoji.dart';
import 'chat_sticker_sheet.dart';

/// The pill at the foot of a conversation, DM style: the field, and on its
/// right the picture button (GIF, the app's emoji and stickers) and the ❤️
/// emoji, which sends a heart while it's empty, or a round send button
/// (Илгээх) once something is typed.
/// Unicode emoji come from the phone's own keyboard.
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    required this.onHeart,
    required this.onMedia,
  });

  /// Called with the trimmed text; the field clears itself afterwards.
  final ValueChanged<String> onSend;
  final VoidCallback onHeart;

  /// Called with the GIF, emoji or sticker picked on the sheet.
  final ValueChanged<ChatMediaPick> onMedia;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _controller = TextEditingController();

  bool get _canSend => _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    if (!_canSend) return;
    widget.onSend(_controller.text.trim());
    _controller.clear();
    setState(() {});
  }

  Future<void> _openSheet() async {
    final pick = await showChatStickerSheet(context);
    if (pick != null) widget.onMedia(pick);
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _canSend;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        6,
        12,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 2, 6, 2),
        decoration: BoxDecoration(
          color: AppColors.slate100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _send(),
                onTapOutside: dismissKeyboard,
                style: inter(size: 15, color: AppColors.slate900),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  hintText: 'Мессеж бичих...',
                  hintStyle: inter(size: 15, color: AppColors.slate400),
                ),
              ),
            ),
            Semantics(
              button: true,
              label: 'GIF, эможи, стикер',
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: withHaptic(_openSheet),
                child: SizedBox(
                  width: 40,
                  height: 44,
                  child: Center(
                    child: LineIcon(
                      LineGlyph.sticker,
                      size: 24,
                      color: AppColors.slate900,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: canSend
                  ? Semantics(
                      button: true,
                      label: 'Илгээх',
                      excludeSemantics: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: withHaptic(_send),
                        // A round accent button with the paper plane.
                        child: SizedBox(
                          width: 44,
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.sky500,
                                shape: BoxShape.circle,
                              ),
                              // Iconsax's bold (filled) plane: the one
                              // filled icon in the app, so it reads as the
                              // action. LineIcon only draws the outlines.
                              child: Icon(
                                Iconsax.send_2,
                                size: 18,
                                color: AppColors.onAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Semantics(
                      button: true,
                      label: 'Зүрх илгээх',
                      excludeSemantics: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onHeart();
                        },
                        child: SizedBox(
                          width: 44,
                          child: Center(
                            // The ❤️ the heart message is drawn with.
                            child: Image.asset(
                              chatReactions.first,
                              width: 28,
                              height: 28,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
