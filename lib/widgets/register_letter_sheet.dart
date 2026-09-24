import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'app_text.dart';

/// The 35 letters of the Mongolian Cyrillic alphabet, in order.
const mongolianLetters = [
  'А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', //
  'Ж', 'З', 'И', 'Й', 'К', 'Л', 'М', //
  'Н', 'О', 'Ө', 'П', 'Р', 'С', 'Т', //
  'У', 'Ү', 'Ф', 'Х', 'Ц', 'Ч', 'Ш', //
  'Щ', 'Ъ', 'Ы', 'Ь', 'Э', 'Ю', 'Я', //
];

/// Opens a [RegisterLetterSheet] on slot [start] and resolves both letters
/// once they are picked, or `null` when the kid closes it.
Future<List<String>?> showRegisterLetterSheet(
  BuildContext context, {
  required List<String?> initial,
  int start = 0,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => RegisterLetterSheet(initial: initial, start: start),
  );
}

/// Bottom-sheet picker for the two letters of a register number: the two
/// slots on top and the whole alphabet below. Picking a letter fills the
/// active slot and moves on to the empty one; the sheet closes once both
/// are filled.
class RegisterLetterSheet extends StatefulWidget {
  const RegisterLetterSheet({super.key, required this.initial, this.start = 0});

  final List<String?> initial;
  final int start;

  @override
  State<RegisterLetterSheet> createState() => _RegisterLetterSheetState();
}

class _RegisterLetterSheetState extends State<RegisterLetterSheet> {
  late final List<String?> _letters = [...widget.initial];
  late int _active = widget.start;

  void _pick(String letter) {
    HapticFeedback.selectionClick();
    setState(() => _letters[_active] = letter);
    final empty = _letters.indexOf(null);
    if (empty == -1) {
      Navigator.of(context).pop(_letters.cast<String>());
      return;
    }
    setState(() => _active = empty);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
            const SizedBox(height: 16),
            AppText(
              'Регистрийн үсэг',
              size: 17,
              weight: FontWeight.w800,
              color: AppColors.slate800,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            AppText(
              'Регистрийн дугаарынхаа 2 үсгийг сонгоно уу',
              size: 12,
              weight: FontWeight.w500,
              color: AppColors.slate500,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _letters.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  _Slot(
                    letter: _letters[i],
                    active: i == _active,
                    semanticLabel: '${i + 1}-р үсэг',
                    onTap: () => setState(() => _active = i),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1,
              children: [
                for (final l in mongolianLetters)
                  _LetterKey(
                    letter: l,
                    selected: _letters[_active] == l,
                    onTap: () => _pick(l),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the two letter slots at the top of the sheet.
class _Slot extends StatelessWidget {
  const _Slot({
    required this.letter,
    required this.active,
    required this.semanticLabel,
    required this.onTap,
  });

  final String? letter;
  final bool active;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active ? AppColors.sky400 : AppColors.slate200,
              width: active ? 2 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.sky400.withValues(alpha: 0.3),
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: AppText(
            letter ?? '',
            size: 22,
            weight: FontWeight.w800,
            color: AppColors.slate800,
          ),
        ),
      ),
    );
  }
}

/// A letter on the alphabet grid.
class _LetterKey extends StatelessWidget {
  const _LetterKey({
    required this.letter,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.sky500 : AppColors.sky50,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Center(
          child: AppText(
            letter,
            size: 17,
            weight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.sky700,
          ),
        ),
      ),
    );
  }
}
