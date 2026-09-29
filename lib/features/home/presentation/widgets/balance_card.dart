import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/accounts.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// The selected account's balance, set large and centred, with its account
/// number, copy and hide controls under it.
class HomeBalance extends StatelessWidget {
  const HomeBalance({
    super.key,
    required this.label,
    required this.account,
    required this.balance,
    required this.hidden,
    required this.limited,
    required this.onToggleHidden,
  });

  final String label;
  final String account;
  final int balance;
  final bool hidden;
  final bool limited;
  final VoidCallback onToggleHidden;

  static TextStyle get _ibanStyle => inter(
    size: 12,
    weight: FontWeight.w500,
    color: Night.text2,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(label, size: 14, weight: FontWeight.w500, color: Night.text2),
        const SizedBox(height: 4),
        SizedBox(
          height: 64,
          child: Center(
            child: FittedBox(
              child: HideableBalance(
                hidden: hidden,
                balance: BalanceText(
                  balance,
                  animate: true,
                  size: 52,
                  weight: FontWeight.w700,
                  letterSpacing: -1.6,
                  color: Colors.white,
                  decimals: true,
                ),
              ),
            ),
          ),
        ),
        if (limited)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: AppText(
              'Хязгаарлагдмал горимын үлдэгдэл',
              size: 11,
              weight: FontWeight.w600,
              color: Night.amber,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Night.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Night.line),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                // Both texts are laid out invisibly underneath so the pill
                // keeps one width, and the shorter masked number sits
                // centred in it.
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.center,
                  children: [
                    for (final text in [formatIban(account), maskIban(account)])
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
                  hidden ? maskIban(account) : formatIban(account),
                  key: ValueKey(hidden),
                  style: _ibanStyle,
                ),
              ),
            ),
            _IconHit(
              icon: LineGlyph.copy,
              label: 'Данс хуулах',
              onTap: () {
                Clipboard.setData(ClipboardData(text: account));
                showAppSnack(context, 'Дансны дугаар хуулагдлаа');
              },
            ),
            EyeToggle(
              hidden: hidden,
              onTap: onToggleHidden,
              size: 18,
              lineColor: Night.text2,
            ),
          ],
        ),
      ],
    );
  }
}

class _IconHit extends StatelessWidget {
  const _IconHit({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final LineGlyph icon;
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
          padding: const EdgeInsets.all(8),
          child: LineIcon(icon, size: 17, color: Night.text2),
        ),
      ),
    );
  }
}

/// The account's actions as two big buttons: mint for the first, white
/// for the second. A single action takes the full width in mint.
class HomeActions extends StatelessWidget {
  const HomeActions({super.key, required this.actions});

  /// (label, icon, onTap).
  final List<(String, LineGlyph, VoidCallback)> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, (label, icon, onTap)) in actions.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _BigAction(
              label: label,
              icon: icon,
              mint: i == 0,
              onTap: onTap,
            ),
          ),
        ],
      ],
    );
  }
}

class _BigAction extends StatelessWidget {
  const _BigAction({
    required this.label,
    required this.icon,
    required this.mint,
    required this.onTap,
  });

  final String label;
  final LineGlyph icon;
  final bool mint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = mint ? AppColors.onAccent : Night.bg;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.96,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: mint ? AppColors.sky500 : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LineIcon(icon, size: 22, color: fg),
              const SizedBox(height: 4),
              AppText(
                label,
                size: 13,
                weight: FontWeight.w700,
                color: fg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
