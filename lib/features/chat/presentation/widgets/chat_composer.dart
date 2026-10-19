import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// The pill at the foot of a conversation, DM style: the field, and on its
/// right a heart that sends a heart while it's empty, or "Илгээх" once
/// something is typed.
class ChatComposer extends StatefulWidget {
  const ChatComposer({super.key, required this.onSend, required this.onHeart});

  /// Called with the trimmed text; the field clears itself afterwards.
  final ValueChanged<String> onSend;
  final VoidCallback onHeart;

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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Center(
                            child: AppText(
                              'Илгээх',
                              size: 15,
                              weight: FontWeight.w700,
                              color: AppColors.sky600,
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
                            // A chrome button: the line stays under 10 too.
                            child: PlainLineIcons(
                              child: LineIcon(
                                LineGlyph.heart,
                                size: 24,
                                color: AppColors.slate900,
                              ),
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
