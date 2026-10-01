import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/accounts.dart';
import '../../../../app/age_group.dart';
import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/card_art.dart';

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
  const HomeActions({super.key, required this.actions, this.art});

  /// (label, icon, onTap).
  final List<(String, LineGlyph, VoidCallback)> actions;

  /// The picture for an action, by label (`accountActionArt`), that replaces
  /// the whole button, label included; null keeps the plain button.
  final String? Function(String label)? art;

  /// How far a row of picture buttons reaches past the page padding on each
  /// side, and the gap between them (wider under 10, whose cartoon pills
  /// run to the edge of their art): the pictures are wide pills whose
  /// height follows their width, so every point of width makes them taller.
  static const _artBleed = 0.0;
  static double get _artGap =>
      appAgeGroup.value == AgeGroup.under10 ? 20.0 : 12.0;

  @override
  Widget build(BuildContext context) {
    final assets = [for (final a in actions) art?.call(a.$1)];
    if (assets.any((a) => a == null)) return _row(8, assets, null);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth + _artBleed * 2;
        final slot = (width - _artGap * (actions.length - 1)) / actions.length;
        // One shape for the whole row, the mean of the pictures' own, so
        // the buttons match in size (each drawn filling it, stretched by a
        // few percent at most); capped like a lone button. Only the width
        // spills past the padding.
        final aspect =
            assets
                .map((a) => actionArtAspect[a] ?? 4.0)
                .reduce((x, y) => x + y) /
            assets.length;
        final height = (slot / aspect).clamp(0.0, _ArtAction.maxHeight);
        return SizedBox(
          height: height,
          child: OverflowBox(
            minWidth: width,
            maxWidth: width,
            // A lone button (Миний өв, Ард койн) keeps its own proportions.
            child: _row(_artGap, assets, actions.length > 1 ? height : null),
          ),
        );
      },
    );
  }

  /// [fillHeight] makes every picture fill a box that tall (a matched pair).
  Widget _row(double gap, List<String?> assets, double? fillHeight) {
    return Row(
      children: [
        for (final (i, (label, icon, onTap)) in actions.indexed) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(
            child: switch (assets[i]) {
              final asset? => _ArtAction(
                label: label,
                asset: asset,
                onTap: onTap,
                fillHeight: fillHeight,
              ),
              null => _BigAction(
                label: label,
                icon: icon,
                primary: i == 0,
                onTap: onTap,
              ),
            },
          ),
        ],
      ],
    );
  }
}

/// A big action drawn as the character's button art, which carries its own
/// label; the label is kept for screen readers.
class _ArtAction extends StatelessWidget {
  const _ArtAction({
    required this.label,
    required this.asset,
    required this.onTap,
    this.fillHeight,
  });

  final String label;
  final String asset;
  final VoidCallback onTap;

  /// Fill a box this tall (and the slot's width), matching the other
  /// button in the row; null keeps the picture's own shape.
  final double? fillHeight;

  static const maxHeight = 72.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.96,
        // In a pair, the row's shared shape; alone, the art's own pill
        // shape, capped so a full-width one (Миний өв, Ард койн) stays
        // button-sized.
        child: SizedBox(
          height: fillHeight ?? maxHeight,
          width: fillHeight == null ? null : double.infinity,
          child: Image.asset(
            asset,
            fit: fillHeight == null ? BoxFit.contain : BoxFit.fill,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, _, _) => Center(
              child: AppText(
                label,
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.slate900,
              ),
            ),
          ),
        ),
      ),
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
