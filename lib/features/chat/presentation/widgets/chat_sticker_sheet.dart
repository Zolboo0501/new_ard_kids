import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/avatar.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/chat_emoji.dart';
import '../../data/chat_stickers.dart';

/// The kinds of picture a [ChatStickerSheet] sends.
enum ChatMedia { gif, emoji, sticker }

/// What was picked on a [ChatStickerSheet] to send at once, by its asset
/// path.
typedef ChatMediaPick = ({String path, ChatMedia kind});

/// Opens a [ChatStickerSheet] and resolves the GIF, emoji or sticker picked,
/// or `null` when it's closed.
Future<ChatMediaPick?> showChatStickerSheet(BuildContext context) {
  return showModalBottomSheet<ChatMediaPick>(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const ChatStickerSheet(),
  );
}

/// The chat's picture panel, three tabs: GIF (empty for now), Эможи (the
/// app's 3D emoji, a round button per category showing one of its own), which it opens on, and Стикер (a
/// row of characters, the teen's own first, and the picked one's nine
/// poses). A pick is sent at once. Every tab keeps the same height so
/// switching doesn't jump.
class ChatStickerSheet extends StatefulWidget {
  const ChatStickerSheet({super.key});

  /// The tabs, in order.
  static const tabs = ['GIF', 'Эможи', 'Стикер'];

  @override
  State<ChatStickerSheet> createState() => _ChatStickerSheetState();
}

class _ChatStickerSheetState extends State<ChatStickerSheet> {
  final _sets = chatStickerSetsFor(appAvatar.value);

  /// Opens on Эможи.
  int _tab = 1;

  /// The character on the Стикер tab, an index into [_sets].
  int _set = 0;

  /// The category on the Эможи tab, an index into [chatEmojiPacks].
  int _pack = 0;

  void _send(String path, ChatMedia kind) {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop<ChatMediaPick>((path: path, kind: kind));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppTabs(
              tabs: [for (final t in ChatStickerSheet.tabs) AppTab(t)],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: switch (_tab) {
                0 => _gifEmpty(),
                1 => _emoji(),
                _ => _stickers(),
              },
            ),
          ],
        ),
      ),
    );
  }

  /// No GIFs yet: the tab stays, empty.
  Widget _gifEmpty() => Center(
    child: AppText(
      'GIF алга байна',
      size: 14,
      color: AppColors.slate500,
      textAlign: TextAlign.center,
    ),
  );

  /// The category chips, then the picked category's emoji.
  Widget _emoji() {
    final pack = chatEmojiPacks[_pack];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final (i, p) in chatEmojiPacks.indexed)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _PackTab(
                  pack: p,
                  selected: i == _pack,
                  onTap: () => setState(() => _pack = i),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.count(
            crossAxisCount: 6,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              for (final (slug, label) in pack.emoji)
                Semantics(
                  button: true,
                  label: label,
                  excludeSemantics: true,
                  child: Pressable(
                    key: ValueKey(pack.path(slug)),
                    scale: 0.85,
                    onTap: () => _send(pack.path(slug), ChatMedia.emoji),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        pack.path(slug),
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// The row of characters, then the picked one's poses.
  Widget _stickers() {
    final set = _sets[_set];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final (i, s) in _sets.indexed)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _SetTab(
                  set: s,
                  selected: i == _set,
                  onTap: () => setState(() => _set = i),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (final path in set.paths)
                _Tile(
                  key: ValueKey(path),
                  label: chatStickerLabel(path),
                  onTap: () => _send(path, ChatMedia.sticker),
                  child: Image.asset(path, filterQuality: FilterQuality.high),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A GIF or sticker on a raised rounded tile; a tap sends it.
class _Tile extends StatelessWidget {
  const _Tile({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        scale: 0.9,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A category on the Эможи tab: one of its emoji on a round button, on the
/// accent's tint when selected.
class _PackTab extends StatelessWidget {
  const _PackTab({
    required this.pack,
    required this.selected,
    required this.onTap,
  });

  final ChatEmojiPack pack;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: pack.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: withHaptic(onTap),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: selected ? AppColors.sky100 : AppColors.slate50,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? AppColors.sky500 : Colors.transparent,
              width: 2,
            ),
          ),
          child: Image.asset(
            pack.path(pack.icon),
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

/// A character on the Стикер tab: its portrait, ringed in the accent when
/// selected.
class _SetTab extends StatelessWidget {
  const _SetTab({
    required this.set,
    required this.selected,
    required this.onTap,
  });

  final ChatStickerSet set;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: set.avatar.name,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: withHaptic(onTap),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? AppColors.sky500 : Colors.transparent,
              width: 2,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.slate50,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(set.avatar.portrait, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
