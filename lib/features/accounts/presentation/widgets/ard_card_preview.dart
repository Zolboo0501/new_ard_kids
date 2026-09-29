import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// The Ard Card as a physical card: a solid ink card (dark on the light
/// canvas, light on the dark one), a chip, the Ard wordmark, and the
/// holder's name printed along the bottom.
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
    // The card is the inverse of the page: primary ink as its face, the
    // canvas colour as its print.
    final face = AppColors.slate900;
    final print = AppColors.surface;
    final muted = print.withValues(alpha: 0.64);
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
              decoration: BoxDecoration(color: face, borderRadius: radius),
              foregroundDecoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: AppColors.line),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    left: 20 * scale,
                    top: 16 * scale,
                    child: Text(
                      'Ard',
                      style: inter(
                        size: 17 * scale,
                        weight: FontWeight.w700,
                        color: print,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16 * scale,
                    top: 16 * scale,
                    child: LineIcon(
                      LineGlyph.contactless,
                      size: 18 * scale,
                      color: muted,
                    ),
                  ),
                  Positioned(
                    left: 22 * scale,
                    top: 50 * scale,
                    child: _Chip(scale: scale),
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

/// The EMV chip, with its contact lines.
class _Chip extends StatelessWidget {
  const _Chip({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30 * scale,
      height: 23 * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.5 * scale),
        color: AppColors.slate400,
      ),
      child: CustomPaint(painter: _ChipLines(scale, AppColors.slate600)),
    );
  }
}

class _ChipLines extends CustomPainter {
  _ChipLines(this.scale, this.color);

  final double scale;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 0.6 * scale
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    canvas.drawLine(Offset(0, h / 3), Offset(w * 0.34, h / 3), p);
    canvas.drawLine(Offset(0, h * 2 / 3), Offset(w * 0.34, h * 2 / 3), p);
    canvas.drawLine(Offset(w * 0.66, h / 3), Offset(w, h / 3), p);
    canvas.drawLine(Offset(w * 0.66, h * 2 / 3), Offset(w, h * 2 / 3), p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.34, h * 0.2, w * 0.66, h * 0.8),
        Radius.circular(2 * scale),
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(_ChipLines old) =>
      old.scale != scale || old.color != color;
}
