import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One account in Home's list: the account's glyph in a quiet tile, its
/// name and a short line, and the balance. A locked account (no parent
/// linked yet) is muted and shows a small lock instead of a balance.
class AccountRow extends StatelessWidget {
  const AccountRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.image,
    this.amount,
    this.onTap,
    this.locked = false,
  });

  final String title;
  final String subtitle;
  final LineGlyph icon;

  /// A picture drawn in place of [icon], such as the 3D Ард койн.
  final String? image;
  final int? amount;
  final VoidCallback? onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: image != null
                  ? Image.asset(
                      image!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      cacheWidth: 160,
                      color: locked ? AppColors.slate50 : null,
                      colorBlendMode: locked ? BlendMode.saturation : null,
                    )
                  : LineIcon(
                      icon,
                      size: 21,
                      color: locked ? AppColors.slate400 : AppColors.slate800,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  size: 14,
                  weight: FontWeight.w600,
                  color: locked ? AppColors.slate500 : AppColors.slate900,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                AppText(
                  subtitle,
                  size: 12,
                  color: AppColors.slate500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (locked)
            Semantics(
              label: 'Түгжээтэй',
              child: LineIcon(
                LineGlyph.lock,
                size: 18,
                color: AppColors.slate400,
              ),
            )
          else ...[
            if (amount != null)
              BalanceText(
                amount!,
                size: 15,
                weight: FontWeight.w600,
                color: AppColors.slate900,
              ),
            if (onTap != null) ...[
              const SizedBox(width: 2),
              LineIcon(
                LineGlyph.chevronRight,
                size: 18,
                color: AppColors.slate500,
              ),
            ],
          ],
        ],
      ),
    );
    if (onTap == null) return row;
    return Pressable(onTap: onTap!, scale: 0.98, child: row);
  }
}
