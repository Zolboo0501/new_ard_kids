import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/accounts.dart';
import '../../../../theme/app_theme.dart';
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // In a tight spot (beside a mascot) the number scales down a little
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
                    moneyStyle(
                      size: 11,
                      weight: FontWeight.w600,
                      color: AppColors.slate400,
                    ),
              ),
            ),
          ),
        ),
        Semantics(
          button: true,
          label: 'Данс хуулах',
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Clipboard.setData(
                ClipboardData(text: number.replaceAll(' ', '')),
              );
              showAppSnack(context, 'Дансны дугаар хуулагдлаа');
            },
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.content_copy_rounded,
                size: 14,
                color: AppColors.slate400,
              ),
            ),
          ),
        ),
        if (onToggleHidden != null)
          EyeToggle(hidden: hidden, onTap: onToggleHidden!),
      ],
    );
  }
}
