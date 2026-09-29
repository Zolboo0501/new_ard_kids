import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/ui.dart';

/// One account in Home's list, on the night surface: an icon in the
/// account's colour, the name and a short line, and the balance.
class AccountRow extends StatelessWidget {
  const AccountRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.mascot,
    this.amount,
    this.onTap,
    this.tileColor,
    this.icon,
    this.trailing,
    this.locked = false,
  });

  final String title;
  final String subtitle;

  /// The companion sticker, shown when there is no [icon].
  final String mascot;
  final int? amount;
  final VoidCallback? onTap;

  /// Unused on the night surface; kept so existing callers still build.
  final Color? tileColor;

  /// The account's glyph, drawn in thin white line.
  final LineGlyph? icon;
  final Widget? trailing;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Night.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: locked ? Night.line : Night.surface),
      ),
      child: Row(
        children: [
          Opacity(
            opacity: locked ? 0.5 : 1,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Night.surface2,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: icon != null
                  ? LineIcon(icon!, size: 21, color: Night.text)
                  : MascotImage(
                      asset: mascot,
                      size: 34,
                      background: Night.surface2,
                      semanticLabel: title,
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
                  color: locked ? Night.text2 : Night.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                AppText(
                  subtitle,
                  size: 12,
                  weight: FontWeight.w500,
                  color: Night.text2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (trailing != null)
            trailing!
          else ...[
            if (amount != null)
              BalanceText(
                amount!,
                size: 15,
                weight: FontWeight.w700,
                color: Night.text,
                decimals: false,
              ),
            const SizedBox(width: 2),
            const LineIcon(
              LineGlyph.chevronRight,
              size: 18,
              color: Night.text2,
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return row;
    return Pressable(onTap: onTap!, scale: 0.98, child: row);
  }
}
