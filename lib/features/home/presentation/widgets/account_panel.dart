import 'package:flutter/material.dart';

import '../../../../app/accounts.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// One of the kid's accounts in Home's carousel: the account's glyph and
/// name, a short line about what it is for, and its masked number. It is an
/// account, not a bank card, so there is no chip or contactless mark; the
/// account's own colour lights the glyph and a soft corner glow.
class HomeAccountPanel extends StatelessWidget {
  const HomeAccountPanel({
    super.key,
    required this.label,
    required this.subtitle,
    required this.account,
    required this.icon,
    required this.accent,
    this.image,
  });

  final String label;
  final String subtitle;
  final String account;
  final LineGlyph icon;
  final Color accent;

  /// A picture drawn in place of [icon], such as the 3D Ард койн.
  final String? image;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // A faint wash of the account's colour from the top-left corner.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-1, -1),
                    radius: 1.2,
                    colors: [
                      accent.withValues(alpha: 0.16),
                      accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
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
                                excludeFromSemantics: true,
                              )
                            : LineIcon(icon, size: 22, color: accent),
                      ),
                    ],
                  ),
                  const Spacer(),
                  AppText(
                    label,
                    size: 17,
                    weight: FontWeight.w700,
                    color: AppColors.slate900,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    subtitle,
                    size: 12,
                    weight: FontWeight.w500,
                    color: AppColors.slate500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    maskIban(account),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        inter(
                          size: 13,
                          weight: FontWeight.w600,
                          color: AppColors.slate900,
                          letterSpacing: 0.6,
                        ).copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
