import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// The kids' card, drawn from [asset] (a white card with a chip and
/// emblem), with the holder's name printed on it.
class KidsCardPreview extends StatelessWidget {
  const KidsCardPreview({super.key, required this.holder, this.number});

  final String holder;

  /// The card number printed above the holder, e.g. `•••• •••• •••• 5521`;
  /// a card still being ordered has none.
  final String? number;

  static const asset = 'assets/svg/card-white.svg';

  /// The artwork's size (its viewBox); the card keeps these proportions.
  static const _artWidth = 243.78;
  static const _artHeight = 153.07;
  static const _artRadius = 9.05;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _artWidth / _artHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Everything on the card scales with its width, like the artwork.
          final scale = constraints.maxWidth / _artWidth;
          final radius = BorderRadius.circular(_artRadius * scale);
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: AppColors.slate900.withValues(alpha: 0.12),
                  offset: const Offset(0, 12),
                  blurRadius: 28,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SvgPicture.asset(
                    asset,
                    fit: BoxFit.fill,
                    semanticsLabel: 'Хүүхдийн карт',
                  ),
                  Positioned(
                    left: 28 * scale,
                    right: 28 * scale,
                    bottom: 16 * scale,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (number != null) ...[
                          Text(
                            number!,
                            style: moneyStyle(
                              size: 11 * scale,
                              weight: FontWeight.w700,
                              color: AppColors.slate700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                        ],
                        AppText(
                          'ЭЗЭМШИГЧ',
                          size: 9,
                          weight: FontWeight.w700,
                          color: AppColors.slate500,
                          letterSpacing: 2,
                        ),
                        AppText(
                          holder,
                          size: 14,
                          weight: FontWeight.w800,
                          color: AppColors.slate900,
                          letterSpacing: 1.2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
