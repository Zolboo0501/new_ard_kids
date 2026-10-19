import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/bank.dart';

/// Every [Bank.all] as a logo over its short name, in one row; the chosen
/// one is outlined in the accent.
class BankPicker extends StatelessWidget {
  const BankPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  /// Index into [Bank.all].
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, bank) in Bank.all.indexed) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _BankTile(
              bank: bank,
              selected: selected == i,
              onTap: () => onChanged(i),
            ),
          ),
        ],
      ],
    );
  }
}

class _BankTile extends StatelessWidget {
  const _BankTile({
    required this.bank,
    required this.selected,
    required this.onTap,
  });

  final Bank bank;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: bank.name,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: withHaptic(onTap),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.sky50 : AppColors.slate50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.sky500 : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              BankLogo(bank: bank, size: 36),
              const SizedBox(height: 6),
              AppText(
                bank.short,
                size: 11,
                weight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.slate900 : AppColors.slate500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A bank's logo on its own white tile, which keeps the logo's colours true
/// on the dark canvas too.
class BankLogo extends StatelessWidget {
  const BankLogo({super.key, required this.bank, this.size = 32});

  final Bank bank;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        // The logos are drawn on white, so the tile stays white in dark mode.
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Image.asset(
        bank.logo,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
