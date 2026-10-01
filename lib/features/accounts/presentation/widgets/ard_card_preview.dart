import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// The Ard Card as a physical card: the white card art (chip and
/// contactless mark included) with the number and holder's
/// name printed along the bottom.
class ArdCardPreview extends StatelessWidget {
  const ArdCardPreview({super.key, required this.holder, this.number});

  final String holder;

  /// The card number printed above the holder, e.g. `•••• •••• •••• 5521`;
  /// a card still being ordered has none.
  final String? number;

  /// The card's design size; everything on it scales with the width.
  static const _artWidth = 243.78;
  static const _artHeight = 153.07;
  static const _artRadius = 11.0;

  @override
  Widget build(BuildContext context) {
    // The card art (`assets/svg/card-white.svg`) is a white card with its own
    // chip and contactless mark; only the print goes on top, in
    // the card's own dark ink so they read on it in either mode.
    const print = Color(0xFF231F20);
    return AspectRatio(
      aspectRatio: _artWidth / _artHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / _artWidth;
          final radius = BorderRadius.circular(_artRadius * scale);
          return Semantics(
            label: 'Ard Card, $holder',
            image: true,
            excludeSemantics: true,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: radius),
              foregroundDecoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: AppColors.line),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SvgPicture.asset(
                    'assets/svg/card-white.svg',
                    fit: BoxFit.fill,
                  ),
                  Positioned(
                    left: 22 * scale,
                    right: 22 * scale,
                    bottom: 14 * scale,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (number != null) ...[
                          Text(
                            number!,
                            style: moneyStyle(
                              size: 12 * scale,
                              weight: FontWeight.w500,
                              color: print,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                        ],
                        AppText(
                          holder,
                          size: 13 * scale,
                          weight: FontWeight.w600,
                          color: print,
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
