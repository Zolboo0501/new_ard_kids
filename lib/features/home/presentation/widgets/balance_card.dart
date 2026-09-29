import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/accounts.dart';
import '../../../../app/kid_profile.dart';
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

  /// Set before a parent is linked: shows the lower daily limit.
  final bool limited;
  final VoidCallback onToggleHidden;

  static TextStyle get _ibanStyle => inter(
    size: 12,
    weight: FontWeight.w500,
    color: AppColors.slate500,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(
          label,
          size: 15,
          weight: FontWeight.w600,
          color: AppColors.slate700,
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 56,
          child: Center(
            child: FittedBox(
              child: HideableBalance(
                hidden: hidden,
                balance: BalanceText(
                  balance,
                  animate: true,
                  size: 44,
                  weight: FontWeight.w700,
                  letterSpacing: -1.2,
                  color: AppColors.slate900,
                  currencyColor: AppColors.slate900,
                  decimals: true,
                ),
              ),
            ),
          ),
        ),
        if (limited)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: AppText(
              'Өдрийн хязгаар ${formatMnt(Limits.unlinkedDaily)}',
              size: 12,
              weight: FontWeight.w600,
              color: AppColors.amber600,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
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
              lineColor: AppColors.slate500,
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
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: LineIcon(icon, size: 18, color: AppColors.slate500),
          ),
        ),
      ),
    );
  }
}

/// The account's actions as two big buttons: the accent fill for the
/// first, a quiet card for the second. A single action takes the full
/// width in the accent.
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
              primary: i == 0,
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
    required this.primary,
    required this.onTap,
  });

  final String label;
  final LineGlyph icon;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = primary ? AppColors.onAccent : AppColors.slate900;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.96,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: primary ? AppColors.sky500 : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primary ? AppColors.sky500 : AppColors.line,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LineIcon(icon, size: 22, color: fg),
              const SizedBox(height: 4),
              AppText(
                label,
                size: 14,
                weight: FontWeight.w600,
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
