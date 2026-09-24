import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/accounts.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/ui.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.label,
    required this.account,
    required this.balance,
    required this.mascot,
    required this.mascotName,
    this.mascotShift = 0,
    required this.hidden,
    required this.limited,
    required this.onToggleHidden,
    required this.actions,
  });

  final String label;
  final String account;
  final int balance;
  final String mascot;
  final String mascotName;

  /// The card's distance from the centre of the carousel, in pages; the
  /// mascot drifts by it so it moves slower than the card (parallax), and
  /// the action buttons rise in by it (see [_SwipeIn]).
  final double mascotShift;
  final bool hidden;
  final bool limited;
  final VoidCallback onToggleHidden;

  /// The buttons along the bottom as (label, sticker, onTap), sharing the
  /// width; the last is the primary one.
  final List<(String, String, VoidCallback)> actions;

  static TextStyle get _ibanStyle =>
      moneyStyle(size: 12, weight: FontWeight.w600, color: AppColors.slate400);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      // Clipped to the card so the mascot's white square never shows past
      // the edge while it drifts during a swipe. The border is drawn on top
      // so the mascot can't cover it either. No shadow: the PageView clips
      // it to a hard-edged rectangle.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.sky100.withValues(alpha: 0.8)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Vertically centred on the card's right side, in the space above
          // the action buttons (50 high).
          Positioned(
            right: -14 + 36 * mascotShift.clamp(-1.0, 1.0),
            top: 0,
            bottom: 50,
            child: Center(
              widthFactor: 1,
              child: MascotImage(
                asset: mascot,
                size: 90,
                background: Colors.white,
                semanticLabel: mascotName,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      label.toUpperCase(),
                      size: 13,
                      weight: FontWeight.w600,
                      color: AppColors.slate400,
                      letterSpacing: 0.6,
                    ),
                  ),
                  // Hides the account number and the balance together. Sits
                  // in the card's right corner so it doesn't move with the
                  // number's width.
                  EyeToggle(
                    hidden: hidden,
                    onTap: onToggleHidden,
                    size: 18,
                    highlighted: true,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sky50,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.sky100.withValues(alpha: 0.6),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      // Both texts are laid out invisibly underneath so the
                      // pill keeps one width, and the shorter masked number
                      // sits centred in it.
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.center,
                        children: [
                          for (final text in [
                            formatIban(account),
                            maskIban(account),
                          ])
                            ExcludeSemantics(
                              child: Text(
                                text,
                                style: _ibanStyle.copyWith(
                                  color: Colors.transparent,
                                ),
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
                  const SizedBox(width: 4),
                  _TinyIcon(
                    icon: Icons.content_copy_rounded,
                    label: 'Данс хуулах',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: account));
                      showAppSnack(context, 'Дансны дугаар хуулагдлаа');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: HideableBalance(
                  hidden: hidden,
                  balance: BalanceText(
                    balance,
                    // Rolls in from ₮0 when the balance is revealed or its
                    // card swipes in.
                    animateFrom: 0,
                    size: 32,
                    weight: FontWeight.w600,
                    letterSpacing: 0.1,
                    currencyWeight: FontWeight.w600,
                    currencyColor: AppColors.slate700,
                  ),
                ),
              ),
              if (limited)
                AppText(
                  'Хязгаарлагдмал горимын үлдэгдэл',
                  size: 10,
                  weight: FontWeight.w600,
                  color: AppColors.amber500,
                ),
              const Spacer(),
              Row(
                children: [
                  for (final (i, (label, sticker, onTap))
                      in actions.indexed) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: _SwipeIn(
                        shift: mascotShift,
                        delay: 0.3 * i,
                        child: _CardAction(
                          label: label,
                          mascot: sticker,
                          primary: i == actions.length - 1,
                          onTap: onTap,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Settles [child] into place as its card swipes to the centre: sunk and
/// faded while the card is off to the side, at rest once it's showing.
///
/// [delay] (0–1) holds a button back so a row of them settles one after
/// another; they leave in the reverse order.
class _SwipeIn extends StatelessWidget {
  const _SwipeIn({
    required this.shift,
    required this.delay,
    required this.child,
  });

  /// The card's distance from the centre, in pages.
  final double shift;
  final double delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // 0 at rest, 1 well before the card is a full page away, so the buttons
    // are out of the way by the time the card is half gone.
    final t = ((shift.abs() * 2 - (0.3 - delay)) / 0.7).clamp(0.0, 1.0);
    if (t == 0) return child;
    return Opacity(
      opacity: 1 - t,
      child: Transform.translate(offset: Offset(0, 18 * t), child: child),
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
          child: Icon(icon, size: 16, color: AppColors.slate400),
        ),
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.label,
    required this.mascot,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final String mascot;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.95,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: primary ? AppColors.sky500 : AppColors.sky50,
            borderRadius: BorderRadius.circular(18),
            border: primary
                ? null
                : Border.all(color: AppColors.sky100.withValues(alpha: 0.8)),
            boxShadow: primary
                ? [
                    BoxShadow(
                      color: AppColors.sky500.withValues(alpha: 0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(2),
                child: MascotImage(
                  asset: mascot,
                  size: 26,
                  background: Colors.white,
                  semanticLabel: '',
                ),
              ),
              const SizedBox(width: 8),
              AppText(
                label,
                size: 13,
                weight: FontWeight.w700,
                color: primary ? Colors.white : AppColors.slate700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
