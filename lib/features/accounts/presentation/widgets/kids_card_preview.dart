import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// The kids' card as a matte black physical card: a faint diagonal sheen, a
/// silver chip, the Ard wordmark with a mint "KIDS", and the holder's name
/// printed along the bottom.
class KidsCardPreview extends StatelessWidget {
  const KidsCardPreview({super.key, required this.holder, this.number});

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
    return AspectRatio(
      aspectRatio: _artWidth / _artHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / _artWidth;
          final radius = BorderRadius.circular(_artRadius * scale);
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2B2D32), Color(0xFF141518), Color(0xFF0B0C0E)],
                stops: [0, 0.55, 1],
              ),
            ),
            // A hairline edge so the black card still reads on the black page.
            foregroundDecoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Semantics(
                  label: 'Хүүхдийн карт',
                  image: true,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // The faint diagonal sheen across the matte finish.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white.withValues(alpha: 0.06),
                              Colors.white.withValues(alpha: 0),
                            ],
                            stops: const [0.25, 0.42, 0.6],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20 * scale,
                        top: 16 * scale,
                        child: ExcludeSemantics(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Ard',
                                  style: inter(
                                    size: 17 * scale,
                                    weight: FontWeight.w800,
                                    color: Night.text,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                TextSpan(
                                  text: ' KIDS',
                                  style: inter(
                                    size: 10 * scale,
                                    weight: FontWeight.w800,
                                    color: AppColors.sky500,
                                    letterSpacing: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16 * scale,
                        top: 16 * scale,
                        child: Icon(
                          Icons.contactless_outlined,
                          size: 18 * scale,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      Positioned(
                        left: 22 * scale,
                        top: 50 * scale,
                        child: _Chip(scale: scale),
                      ),
                    ],
                  ),
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
                            size: 11 * scale,
                            weight: FontWeight.w600,
                            color: Night.text,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                      ],
                      AppText(
                        'ЭЗЭМШИГЧ',
                        size: 9,
                        weight: FontWeight.w700,
                        color: Night.text2,
                        letterSpacing: 2,
                      ),
                      AppText(
                        holder,
                        size: 14,
                        weight: FontWeight.w800,
                        color: Night.text,
                        letterSpacing: 1.2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The silver EMV chip, with its contact lines.
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE4E6EA), Color(0xFF9EA2AA), Color(0xFFD2D5DA)],
        ),
      ),
      child: CustomPaint(painter: _ChipLines(scale)),
    );
  }
}

class _ChipLines extends CustomPainter {
  _ChipLines(this.scale);

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF6E727A).withValues(alpha: 0.7)
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
  bool shouldRepaint(_ChipLines old) => old.scale != scale;
}
