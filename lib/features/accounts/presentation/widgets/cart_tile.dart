import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/cart_item.dart';
import 'account_glyph_tile.dart';

/// One item in the cart: category tile, store over title and price, a
/// remove button and the quantity stepper.
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
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      child: Row(
        children: [
          AccountGlyphTile(item.glyph),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  item.title,
                  size: 14,
                  weight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                AppText(item.store, size: 12, color: AppColors.slate500),
                const SizedBox(height: 4),
                BalanceText(
                  item.price * item.quantity,
                  animate: true,
                  size: 14,
                  weight: FontWeight.w600,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _IconButton(
                glyph: LineGlyph.close,
                label: 'Сагснаас хасах',
                onTap: onRemove,
              ),
              Row(
                children: [
                  _IconButton(
                    glyph: LineGlyph.minus,
                    label: 'Тоо хасах',
                    onTap: item.quantity > 1
                        ? () => onChanged(item.quantity - 1)
                        : null,
                  ),
                  SizedBox(
                    width: 20,
                    child: AppText(
                      '${item.quantity}',
                      size: 14,
                      weight: FontWeight.w600,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  _IconButton(
                    glyph: LineGlyph.plus,
                    label: 'Тоо нэмэх',
                    onTap: () => onChanged(item.quantity + 1),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A 44pt tap target around a small line glyph.
class _IconButton extends StatelessWidget {
  const _IconButton({required this.glyph, required this.label, this.onTap});

  final LineGlyph glyph;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: withHaptic(onTap),
        child: SizedBox.square(
          dimension: 44,
          child: Center(
            child: LineIcon(
              glyph,
              size: 18,
              color: onTap == null ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
        ),
      ),
    );
  }
}
