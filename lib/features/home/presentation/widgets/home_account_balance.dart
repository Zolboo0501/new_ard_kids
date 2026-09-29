import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/accounts.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/home_account.dart';

/// The balance of the account in the centre of Home's carousel, with its
/// full number underneath. The eye button hides the number and the balance
/// together.
class HomeAccountBalance extends StatelessWidget {
  const HomeAccountBalance({
    super.key,
    required this.account,
    required this.hidden,
    required this.limited,
    required this.onToggleHidden,
  });

  final HomeAccount account;
  final bool hidden;
  final bool limited;
  final VoidCallback onToggleHidden;

  static TextStyle get _ibanStyle =>
      moneyStyle(size: 12, weight: FontWeight.w600, color: AppColors.slate500);

  @override
  Widget build(BuildContext context) {
    final iban = account.iban;
    return Column(
      children: [
        AppText(
          account.label,
          size: 14,
          weight: FontWeight.w500,
          color: AppColors.slate500,
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 54,
          // Scaled down rather than cut on a narrow pane.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: HideableBalance(
              hidden: hidden,
              alignment: Alignment.center,
              balance: BalanceText(
                account.balance,
                // Rolls in from ₮0 when the balance is revealed or its
                // card comes to the centre.
                animateFrom: 0,
                size: 42,
                weight: FontWeight.w700,
                letterSpacing: -0.6,
                currencyWeight: FontWeight.w700,
                currencyColor: AppColors.slate700,
                decimals: true,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        if (limited) ...[
          const SizedBox(height: 2),
          AppText(
            'Хязгаарлагдмал горимын үлдэгдэл',
            size: 11,
            weight: FontWeight.w600,
            color: AppColors.amber500,
          ),
        ],
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.sky100),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                // Both texts are laid out invisibly underneath so the
                // pill keeps one width, and the shorter masked number
                // sits centred in it.
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.center,
                  children: [
                    for (final text in [formatIban(iban), maskIban(iban)])
                      ExcludeSemantics(
                        child: Text(
                          text,
                          style: _ibanStyle.copyWith(color: Colors.transparent),
                        ),
                      ),
                    ...previous,
                    ?current,
                  ],
                ),
                child: Text(
                  hidden ? maskIban(iban) : formatIban(iban),
                  key: ValueKey(hidden),
                  style: _ibanStyle,
                ),
              ),
            ),
            const SizedBox(width: 4),
            _TinyIcon(
              icon: Icons.content_copy_rounded,
              label: 'Данс хуулах',
              onTap: () {
                Clipboard.setData(ClipboardData(text: iban));
                showAppSnack(context, 'Дансны дугаар хуулагдлаа');
              },
            ),
            EyeToggle(hidden: hidden, onTap: onToggleHidden, size: 18),
          ],
        ),
      ],
    );
  }
}

class _TinyIcon extends StatelessWidget {
  const _TinyIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: withHaptic(onTap),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 17, color: AppColors.slate400),
        ),
      ),
    );
  }
}
