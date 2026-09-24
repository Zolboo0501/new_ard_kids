import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

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

  /// An amount (shown with [BalanceText]) or text such as `ҮНЭГҮЙ`.
  final Object price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? AppColors.sky50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.slate200,
              width: selected ? 2 : 1,
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
                      size: 12,
                      weight: FontWeight.w700,
                      color: selected ? AppColors.sky900 : AppColors.slate700,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.sky500 : Colors.white,
                      border: selected
                          ? null
                          : Border.all(color: AppColors.slate300),
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 11,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AppText(subtitle, size: 10, color: AppColors.slate500),
              const SizedBox(height: 4),
              switch (price) {
                final num amount => BalanceText(
                  amount,
                  space: false,
                  size: 11,
                  weight: FontWeight.w800,
                  color: selected ? AppColors.sky700 : AppColors.emerald600,
                ),
                _ => Text(
                  '$price',
                  style: moneyStyle(
                    size: 11,
                    weight: FontWeight.w800,
                    color: selected ? AppColors.sky700 : AppColors.emerald600,
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
