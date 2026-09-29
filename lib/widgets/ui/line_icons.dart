import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The app's own line icons, drawn instead of Material's: one thin 1.5
/// stroke on a 24 grid with round caps and joins, like the reference's
/// narrow white icons. Pick a glyph and a colour; size scales the stroke.
enum LineGlyph {
  eye,
  eyeOff,
  home,
  profile,
  scan,
  bell,
  bellRing,
  settings,
  arrowUpRight,
  arrowDownLeft,
  arrowRight,
  chevronRight,
  plus,
  close,
  personAdd,
  contactless,
  copy,
  card,
  cardAdd,
  info,
  clock,
  flame,
  bolt,
  coins,
  trend,
  crown,
  sparkleCoin,
  wallet,
  receipt,
  plusCircle,
  banknote,

  /// The account glyphs on Home: a pocket (Халаасны данс), a piggy bank
  /// (Хадгаламж), a sprout (Миний өв), a gift (Урамшуулал) and the Ard
  /// coin (Ард койн).
  pocket,
  piggy,
  sprout,
  gift,
  ardCoin,

  /// The two big Home buttons: a paper plane for Гүйлгээ (money flies off
  /// like a message) and a charging battery for Цэнэглэх.
  paperPlane,
  charge,
}

class LineIcon extends StatelessWidget {
  const LineIcon(
    this.glyph, {
    super.key,
    this.size = 24,
    required this.color,
    this.stroke = 1.5,
    this.semanticLabel,
  });

  final LineGlyph glyph;
  final double size;
  final Color color;

  /// Line width in grid units (the icon is 24 wide).
  final double stroke;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final icon = SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _LinePainter(glyph, color, stroke)),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: icon);
    return Semantics(label: semanticLabel, child: icon);
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.glyph, this.color, this.stroke);

  final LineGlyph glyph;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..scale(size.width / 24)
      ..drawPath(
        _path(glyph),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true
          ..color = color,
      );
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.glyph != glyph || old.color != color || old.stroke != stroke;

  static Rect _r(double l, double t, double w, double h) =>
      Rect.fromLTWH(l, t, w, h);

  static Path _circle(Path p, double x, double y, double r) =>
      p..addOval(Rect.fromCircle(center: Offset(x, y), radius: r));

  /// A dot: a zero-length stroke, drawn round by its cap.
  static void _dot(Path p, double x, double y) => p
    ..moveTo(x, y)
    ..lineTo(x, y + 0.01);

  static Path _bell(Path p) => p
    ..moveTo(6.5, 16.5)
    ..lineTo(6.5, 11)
    ..cubicTo(6.5, 7.9, 9, 5.5, 12, 5.5)
    ..cubicTo(15, 5.5, 17.5, 7.9, 17.5, 11)
    ..lineTo(17.5, 16.5)
    ..moveTo(4.5, 16.5)
    ..lineTo(19.5, 16.5)
    ..moveTo(10, 19.5)
    ..quadraticBezierTo(12, 21, 14, 19.5)
    ..moveTo(12, 3.5)
    ..lineTo(12, 5.5);

  static Path _path(LineGlyph g) {
    final p = Path();
    switch (g) {
      case LineGlyph.eye:
      case LineGlyph.eyeOff:
        p
          ..moveTo(2.5, 12)
          ..cubicTo(4.8, 7.8, 8.2, 5.5, 12, 5.5)
          ..cubicTo(15.8, 5.5, 19.2, 7.8, 21.5, 12)
          ..cubicTo(19.2, 16.2, 15.8, 18.5, 12, 18.5)
          ..cubicTo(8.2, 18.5, 4.8, 16.2, 2.5, 12)
          ..close();
        _circle(p, 12, 12, 3);
        if (g == LineGlyph.eyeOff) {
          p
            ..moveTo(4, 4)
            ..lineTo(20, 20);
        }
      case LineGlyph.home:
        p
          ..moveTo(3.5, 11)
          ..lineTo(12, 4)
          ..lineTo(20.5, 11)
          ..moveTo(6, 9.5)
          ..lineTo(6, 19.5)
          ..lineTo(18, 19.5)
          ..lineTo(18, 9.5)
          ..moveTo(10, 19.5)
          ..lineTo(10, 15)
          ..lineTo(14, 15)
          ..lineTo(14, 19.5);
      case LineGlyph.profile:
        _circle(p, 12, 8.5, 3.6);
        p
          ..moveTo(5, 20)
          ..cubicTo(5, 16, 8, 13.8, 12, 13.8)
          ..cubicTo(16, 13.8, 19, 16, 19, 20);
      case LineGlyph.scan:
        p
          ..moveTo(4, 8.5)
          ..lineTo(4, 6)
          ..quadraticBezierTo(4, 4, 6, 4)
          ..lineTo(8.5, 4)
          ..moveTo(15.5, 4)
          ..lineTo(18, 4)
          ..quadraticBezierTo(20, 4, 20, 6)
          ..lineTo(20, 8.5)
          ..moveTo(20, 15.5)
          ..lineTo(20, 18)
          ..quadraticBezierTo(20, 20, 18, 20)
          ..lineTo(15.5, 20)
          ..moveTo(8.5, 20)
          ..lineTo(6, 20)
          ..quadraticBezierTo(4, 20, 4, 18)
          ..lineTo(4, 15.5)
          ..moveTo(7.5, 12)
          ..lineTo(16.5, 12);
      case LineGlyph.bell:
        _bell(p);
      case LineGlyph.bellRing:
        _bell(p)
          ..moveTo(3, 9)
          ..quadraticBezierTo(3.4, 6.2, 5.4, 4.5)
          ..moveTo(21, 9)
          ..quadraticBezierTo(20.6, 6.2, 18.6, 4.5);
      case LineGlyph.settings:
        // Eight squared-off teeth around a hub.
        Offset at(double r, double deg) {
          final a = deg * math.pi / 180;
          return Offset(12 + r * math.cos(a), 12 + r * math.sin(a));
        }
        for (var k = 0; k < 8; k++) {
          final base = k * 45.0;
          final pts = [
            at(6.9, base - 15),
            at(9.3, base - 8),
            at(9.3, base + 8),
            at(6.9, base + 15),
          ];
          if (k == 0) {
            p.moveTo(pts[0].dx, pts[0].dy);
          } else {
            p.lineTo(pts[0].dx, pts[0].dy);
          }
          for (final q in pts.skip(1)) {
            p.lineTo(q.dx, q.dy);
          }
        }
        p.close();
        _circle(p, 12, 12, 2.8);
      case LineGlyph.arrowUpRight:
        p
          ..moveTo(6.5, 17.5)
          ..lineTo(17.5, 6.5)
          ..moveTo(8.5, 6.5)
          ..lineTo(17.5, 6.5)
          ..lineTo(17.5, 15.5);
      case LineGlyph.arrowDownLeft:
        p
          ..moveTo(17.5, 6.5)
          ..lineTo(6.5, 17.5)
          ..moveTo(6.5, 8.5)
          ..lineTo(6.5, 17.5)
          ..lineTo(15.5, 17.5);
      case LineGlyph.arrowRight:
        p
          ..moveTo(4, 12)
          ..lineTo(20, 12)
          ..moveTo(14, 6)
          ..lineTo(20, 12)
          ..lineTo(14, 18);
      case LineGlyph.chevronRight:
        p
          ..moveTo(9.5, 6)
          ..lineTo(15.5, 12)
          ..lineTo(9.5, 18);
      case LineGlyph.plus:
        p
          ..moveTo(12, 5)
          ..lineTo(12, 19)
          ..moveTo(5, 12)
          ..lineTo(19, 12);
      case LineGlyph.close:
        p
          ..moveTo(6.5, 6.5)
          ..lineTo(17.5, 17.5)
          ..moveTo(17.5, 6.5)
          ..lineTo(6.5, 17.5);
      case LineGlyph.personAdd:
        // A head on shoulders, with a plus beside it.
        _circle(p, 10, 8, 3.75);
        p
          ..moveTo(3, 20)
          ..cubicTo(3, 16.1, 6.1, 14.25, 10, 14.25)
          ..cubicTo(12.1, 14.25, 13.9, 14.8, 15.2, 15.9)
          ..moveTo(19, 12.5)
          ..lineTo(19, 18.5)
          ..moveTo(16, 15.5)
          ..lineTo(22, 15.5);
      case LineGlyph.contactless:
        for (final r in [4.5, 8.5, 12.5]) {
          p.addArc(
            Rect.fromCircle(center: const Offset(5, 12), radius: r),
            -0.75,
            1.5,
          );
        }
      case LineGlyph.copy:
        p
          ..addRRect(
            RRect.fromRectAndRadius(
              _r(8.5, 8.5, 11.5, 11.5),
              const Radius.circular(2.5),
            ),
          )
          ..moveTo(4, 15.5)
          ..lineTo(4, 6.5)
          ..quadraticBezierTo(4, 4, 6.5, 4)
          ..lineTo(15.5, 4);
      case LineGlyph.card:
        p
          ..addRRect(
            RRect.fromRectAndRadius(
              _r(3, 5.5, 18, 13),
              const Radius.circular(2.5),
            ),
          )
          ..moveTo(3, 10)
          ..lineTo(21, 10)
          ..moveTo(6.5, 14.8)
          ..lineTo(10, 14.8);
      case LineGlyph.cardAdd:
        p
          ..moveTo(15, 17.5)
          ..lineTo(5, 17.5)
          ..quadraticBezierTo(2.5, 17.5, 2.5, 15)
          ..lineTo(2.5, 7.5)
          ..quadraticBezierTo(2.5, 5, 5, 5)
          ..lineTo(17.5, 5)
          ..quadraticBezierTo(20, 5, 20, 7.5)
          ..lineTo(20, 11)
          ..moveTo(2.5, 9.5)
          ..lineTo(20, 9.5)
          ..moveTo(19, 14)
          ..lineTo(19, 21)
          ..moveTo(15.5, 17.5)
          ..lineTo(22.5, 17.5);
      case LineGlyph.info:
        _circle(p, 12, 12, 9);
        p
          ..moveTo(12, 11)
          ..lineTo(12, 16.5);
        _dot(p, 12, 7.8);
      case LineGlyph.clock:
        _circle(p, 12, 12, 9);
        p
          ..moveTo(12, 7.5)
          ..lineTo(12, 12)
          ..lineTo(15, 14);
      case LineGlyph.flame:
        p
          ..moveTo(12, 3)
          ..cubicTo(15, 5.8, 18.5, 9.3, 18.5, 13.8)
          ..cubicTo(18.5, 17.6, 15.6, 20.5, 12, 20.5)
          ..cubicTo(8.4, 20.5, 5.5, 17.6, 5.5, 13.8)
          ..cubicTo(5.5, 11, 7, 9.2, 8.6, 7.8)
          ..cubicTo(8.8, 10, 9.8, 11.6, 11.2, 12)
          ..cubicTo(10.6, 8.6, 11.2, 5.6, 12, 3)
          ..close()
          ..moveTo(12, 17.8)
          ..cubicTo(10.6, 17.8, 9.8, 16.8, 9.8, 15.7)
          ..cubicTo(9.8, 14.4, 11, 13.4, 12, 12.6)
          ..cubicTo(13, 13.4, 14.2, 14.4, 14.2, 15.7)
          ..cubicTo(14.2, 16.8, 13.4, 17.8, 12, 17.8);
      case LineGlyph.bolt:
        p
          ..moveTo(13.5, 3)
          ..lineTo(5.5, 13.5)
          ..lineTo(11.5, 13.5)
          ..lineTo(10.5, 21)
          ..lineTo(18.5, 10.5)
          ..lineTo(12.5, 10.5)
          ..close();
      case LineGlyph.coins:
        // The mascot's ₮ coin, with a second coin stacked behind it.
        _circle(p, 14.5, 12, 7);
        p
          ..addArc(
            Rect.fromCircle(center: const Offset(9.5, 12), radius: 7),
            1.95,
            2.4,
          )
          ..moveTo(11.8, 9.3)
          ..lineTo(17.2, 9.3)
          ..moveTo(14.5, 9.3)
          ..lineTo(14.5, 15.8)
          ..moveTo(12.6, 12.6)
          ..lineTo(16.4, 11.6)
          ..moveTo(12.6, 14.7)
          ..lineTo(16.4, 13.7);
      case LineGlyph.trend:
        p
          ..moveTo(3, 17)
          ..lineTo(9, 11)
          ..lineTo(13, 15)
          ..lineTo(21, 7)
          ..moveTo(15.5, 7)
          ..lineTo(21, 7)
          ..lineTo(21, 12.5);
      case LineGlyph.crown:
        p
          ..moveTo(4.5, 17)
          ..lineTo(3, 7.5)
          ..lineTo(8.5, 11.5)
          ..lineTo(12, 5)
          ..lineTo(15.5, 11.5)
          ..lineTo(21, 7.5)
          ..lineTo(19.5, 17)
          ..close()
          ..moveTo(5, 20.5)
          ..lineTo(19, 20.5);
      case LineGlyph.sparkleCoin:
        _circle(p, 12, 12, 9);
        p
          ..moveTo(12, 7)
          ..quadraticBezierTo(12.6, 11.4, 17, 12)
          ..quadraticBezierTo(12.6, 12.6, 12, 17)
          ..quadraticBezierTo(11.4, 12.6, 7, 12)
          ..quadraticBezierTo(11.4, 11.4, 12, 7)
          ..close();
      case LineGlyph.wallet:
        p
          ..addRRect(
            RRect.fromRectAndRadius(
              _r(3, 6.5, 18, 13.5),
              const Radius.circular(3),
            ),
          )
          ..moveTo(6, 6.5)
          ..lineTo(15.3, 3.9)
          ..quadraticBezierTo(17, 3.4, 17, 5.2)
          ..lineTo(17, 6.5)
          ..moveTo(21, 10.5)
          ..lineTo(17, 10.5)
          ..quadraticBezierTo(14.5, 10.5, 14.5, 13.2)
          ..quadraticBezierTo(14.5, 16, 17, 16)
          ..lineTo(21, 16);
        _dot(p, 17.4, 13.2);
      case LineGlyph.receipt:
        p
          ..moveTo(6, 3.5)
          ..lineTo(18, 3.5)
          ..lineTo(18, 20.5)
          ..lineTo(16, 19)
          ..lineTo(14, 20.5)
          ..lineTo(12, 19)
          ..lineTo(10, 20.5)
          ..lineTo(8, 19)
          ..lineTo(6, 20.5)
          ..close()
          ..moveTo(9, 8.5)
          ..lineTo(15, 8.5)
          ..moveTo(9, 12)
          ..lineTo(15, 12)
          ..moveTo(9, 15.5)
          ..lineTo(12, 15.5);
      case LineGlyph.plusCircle:
        _circle(p, 12, 12, 9);
        p
          ..moveTo(12, 8)
          ..lineTo(12, 16)
          ..moveTo(8, 12)
          ..lineTo(16, 12);
      case LineGlyph.banknote:
        p.addRRect(
          RRect.fromRectAndRadius(
            _r(2.5, 6, 19, 12),
            const Radius.circular(2.5),
          ),
        );
        _circle(p, 12, 12, 2.8);
        _dot(p, 6, 12);
        _dot(p, 18, 12);
      case LineGlyph.pocket:
        // A wallet: the body, and a small tab on the right with a dot.
        p
          ..moveTo(21, 9)
          ..lineTo(21, 7.5)
          ..cubicTo(21, 6.1, 19.9, 5, 18.5, 5)
          ..lineTo(5.5, 5)
          ..cubicTo(4.1, 5, 3, 6.1, 3, 7.5)
          ..lineTo(3, 16.5)
          ..cubicTo(3, 17.9, 4.1, 19, 5.5, 19)
          ..lineTo(18.5, 19)
          ..cubicTo(19.9, 19, 21, 17.9, 21, 16.5)
          ..lineTo(21, 15)
          ..moveTo(21, 9)
          ..lineTo(16.5, 9)
          ..cubicTo(14.8, 9, 13.5, 10.3, 13.5, 12)
          ..cubicTo(13.5, 13.7, 14.8, 15, 16.5, 15)
          ..lineTo(21, 15)
          ..lineTo(21, 9)
          ..close();
        _dot(p, 16.75, 12);
      case LineGlyph.piggy:
        // A piggy bank: one round body, an ear, the snout, two feet, and
        // the slot on its back.
        p
          ..moveTo(6, 10.5)
          ..cubicTo(6, 7.5, 8.7, 6, 12, 6)
          ..cubicTo(15.9, 6, 19, 8.3, 19, 12)
          ..cubicTo(19, 14.1, 18.1, 15.6, 16.8, 16.6)
          ..lineTo(16.8, 19)
          ..lineTo(14.3, 19)
          ..lineTo(14.3, 17.5)
          ..lineTo(9.7, 17.5)
          ..lineTo(9.7, 19)
          ..lineTo(7.2, 19)
          ..lineTo(7.2, 16.4)
          ..cubicTo(6.5, 15.8, 6.1, 15.1, 6, 14.3)
          ..lineTo(4, 14.3)
          ..lineTo(4, 10.5)
          ..close()
          ..moveTo(7.5, 7.2)
          ..lineTo(7.5, 4.5)
          ..lineTo(10.3, 6.2)
          ..moveTo(11, 3.5)
          ..lineTo(14, 3.5);
        _dot(p, 15.5, 11);
      case LineGlyph.sprout:
        // A seedling: a stem from the ground with one leaf each side.
        p
          ..moveTo(4, 20.5)
          ..lineTo(20, 20.5)
          ..moveTo(12, 20.5)
          ..lineTo(12, 10)
          ..moveTo(12, 14)
          ..cubicTo(12, 11, 9.8, 9, 6, 9)
          ..cubicTo(6, 12.2, 8.2, 14, 12, 14)
          ..moveTo(12, 10)
          ..cubicTo(12, 6.5, 14.5, 4, 18.5, 4)
          ..cubicTo(18.5, 7.8, 16, 10, 12, 10);
      case LineGlyph.gift:
        // A gift box: the lid as a wide band, the box under it, a ribbon
        // down the middle and a bow of two loops.
        p
          ..addRRect(
            RRect.fromRectAndRadius(
              _r(3, 8, 18, 4.5),
              const Radius.circular(1.5),
            ),
          )
          ..moveTo(5, 12.5)
          ..lineTo(5, 18.5)
          ..cubicTo(5, 19.6, 5.9, 20.5, 7, 20.5)
          ..lineTo(17, 20.5)
          ..cubicTo(18.1, 20.5, 19, 19.6, 19, 18.5)
          ..lineTo(19, 12.5)
          ..moveTo(12, 8)
          ..lineTo(12, 20.5)
          ..moveTo(12, 8)
          ..cubicTo(9.6, 8, 7.4, 7, 7.4, 5.4)
          ..cubicTo(7.4, 4.4, 8.2, 3.5, 9.3, 3.5)
          ..cubicTo(10.9, 3.5, 12, 6, 12, 8)
          ..cubicTo(12, 6, 13.1, 3.5, 14.7, 3.5)
          ..cubicTo(15.8, 3.5, 16.6, 4.4, 16.6, 5.4)
          ..cubicTo(16.6, 7, 14.4, 8, 12, 8);
      case LineGlyph.ardCoin:
        // A coin with the letter А.
        _circle(p, 12, 12, 9);
        p
          ..moveTo(8.75, 16)
          ..lineTo(12, 7.75)
          ..lineTo(15.25, 16)
          ..moveTo(9.9, 13.25)
          ..lineTo(14.1, 13.25);
      case LineGlyph.paperPlane:
        // A paper plane pointing up-right, with the fold down its middle.
        p
          ..moveTo(20.5, 3.5)
          ..lineTo(3.5, 10.5)
          ..lineTo(10.5, 13.5)
          ..lineTo(13.5, 20.5)
          ..close()
          ..moveTo(10.5, 13.5)
          ..lineTo(20.5, 3.5);
      case LineGlyph.charge:
        // A battery lying down with a bolt inside.
        p
          ..addRRect(
            RRect.fromRectAndRadius(
              _r(2.5, 7, 16.5, 10),
              const Radius.circular(2.5),
            ),
          )
          ..moveTo(19, 10)
          ..lineTo(20, 10)
          ..cubicTo(20.8, 10, 21.5, 10.7, 21.5, 11.5)
          ..lineTo(21.5, 12.5)
          ..cubicTo(21.5, 13.3, 20.8, 14, 20, 14)
          ..lineTo(19, 14)
          ..moveTo(11.5, 8.5)
          ..lineTo(8, 12.5)
          ..lineTo(11, 12.5)
          ..lineTo(9.5, 15.5)
          ..lineTo(13, 11.5)
          ..lineTo(10, 11.5)
          ..close();
    }
    return p;
  }
}
