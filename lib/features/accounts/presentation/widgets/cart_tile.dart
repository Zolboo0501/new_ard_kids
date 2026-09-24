import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/cart_item.dart';

class CartTile extends StatelessWidget {
  const CartTile({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onChanged,
  });

  final CartItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 14,
      padding: const EdgeInsets.all(10),
      borderColor: AppColors.slate100,
      child: Row(
        children: [
          MascotTile(
            asset: item.asset,
            size: 56,
            background: item.tint,
            radius: 12,
            label: item.title,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(label: item.store, tone: BadgeTone.slate),
                const SizedBox(height: 3),
                AppText(
                  item.title,
                  size: 12,
                  weight: FontWeight.w700,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                BalanceText(
                  item.price * item.quantity,
                  animate: true,
                  space: false,
                  size: 12,
                  weight: FontWeight.w800,
                  color: AppColors.slate900,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Semantics(
                button: true,
                label: 'Хасах',
                child: GestureDetector(
                  onTap: withHaptic(onRemove),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.slate400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove_rounded,
                      label: 'Хасах',
                      onTap: item.quantity > 1
                          ? () => onChanged(item.quantity - 1)
                          : null,
                    ),
                    SizedBox(
                      width: 22,
                      child: AppText(
                        '${item.quantity}',
                        size: 12,
                        weight: FontWeight.w700,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add_rounded,
                      label: 'Нэмэх',
                      onTap: () => onChanged(item.quantity + 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: withHaptic(onTap),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: onTap == null ? AppColors.slate300 : AppColors.slate600,
          ),
        ),
      ),
    );
  }
}
