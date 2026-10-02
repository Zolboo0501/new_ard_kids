import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/accounts.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/avatar_card_art.dart';
import '../../../../widgets/ui.dart';

/// An account's IBAN, printed in full in blocks of four, with a button that
/// copies it without the spaces.
///
/// With [onToggleHidden] it also gets the screen's eye button, which hides
/// the number ([maskIban]) together with the balance: pass the same flag to
/// [HideableBalance].
class CopyAccountNumber extends StatelessWidget {
  const CopyAccountNumber({
    super.key,
    required this.number,
    this.prefix = '',
    this.style,
    this.hidden = false,
    this.onToggleHidden,
  });

  /// The IBAN, grouped or not (see [Accounts]).
  final String number;
  final String prefix;
  final TextStyle? style;
  final bool hidden;
  final VoidCallback? onToggleHidden;

  @override
  Widget build(BuildContext context) {
    // On card art the number sits on a wash of the character's colours
    // rather than on the flat card, so the faintest grey loses its edge:
    // step it up so it reads as clearly as it does on a plain card.
    final ink = AvatarCardArt.artUnder(context)
        ? AppColors.slate700
        : AppColors.slate500;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // In a tight spot the number scales down a little
        // rather than pushing the buttons off the card.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.centerLeft,
                children: [...previous, ?current],
              ),
              child: Text(
                '$prefix${hidden ? maskIban(number) : formatIban(number)}',
                key: ValueKey(hidden),
                style:
                    style ??
                    moneyStyle(size: 13, weight: FontWeight.w500, color: ink),
              ),
            ),
          ),
        ),
        Semantics(
          button: true,
          label: 'Данс хуулах',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              Clipboard.setData(
                ClipboardData(text: number.replaceAll(' ', '')),
              );
              showAppSnack(context, 'Дансны дугаар хуулагдлаа');
            },
            child: SizedBox.square(
              dimension: 44,
              child: Center(
                child: LineIcon(LineGlyph.copy, size: 16, color: ink),
              ),
            ),
          ),
        ),
        if (onToggleHidden != null)
          EyeToggle(
            hidden: hidden,
            onTap: onToggleHidden!,
            size: 18,
            lineColor: ink,
          ),
      ],
    );
  }
}
