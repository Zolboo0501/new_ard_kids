import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// A delivery choice on "Карт захиалга"; the selected one gets the accent
/// border and a filled check.
class DeliveryOption extends StatelessWidget {
  const DeliveryOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;

  /// An amount (shown with [BalanceText]) or text such as `Үнэгүй`.
  final Object price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? AppColors.sky50 : AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.sky500 : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      title,
                      size: 14,
                      weight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.sky500 : Colors.transparent,
                      border: selected
                          ? null
                          : Border.all(color: AppColors.slate300),
                    ),
                    child: selected
                        ? LineIcon(
                            LineGlyph.check,
                            size: 14,
                            stroke: 2,
                            color: AppColors.onAccent,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AppText(subtitle, size: 12, color: AppColors.slate500),
              const SizedBox(height: 8),
              switch (price) {
                final num amount => BalanceText(
                  amount,
                  space: false,
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.slate900,
                ),
                _ => Text(
                  '$price',
                  style: moneyStyle(
                    size: 14,
                    weight: FontWeight.w600,
                    color: AppColors.slate900,
                  ),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}
