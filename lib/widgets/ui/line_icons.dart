import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/age_group.dart';
import '../../app/avatar.dart';

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

  /// General-purpose glyphs that replace the sticker illustrations on list
  /// rows, heroes and settings.
  check,
  checkCircle,
  alert,
  lock,
  shield,
  fingerprint,
  faceId,
  phone,
  target,
  calendar,
  chart,
  calculator,
  users,
  link,
  food,
  bus,
  shirt,
  gamepad,
  book,
  bag,
  star,
  heart,
  qr,
  bank,
  edit,
  logout,
  help,
  moon,
  sun,
  palette,
  graduation,
  trophy,
  percent,
  snowflake,
  search,
  mail,
  camera,
  ball,
  plane,
  history,
  minus,
  chevronLeft,
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

  /// Under 10 the content glyphs (piggy, gift, card, QR…) are drawn as the
  /// chosen companion's sticker for the same thing, so every screen's icons
  /// follow the avatar. Chrome glyphs (arrows, chevrons, close, eye, plus…)
  /// and tiny inline icons stay as lines.
  /// Screens under [PlainLineIcons] (sign-in and the auth steps) keep the
  /// lines.
  static String? kidsSticker(LineGlyph glyph, double size) {
    if (appAgeGroup.value != AgeGroup.under10 || size < _stickerMin) {
      return null;
    }
    return switch (glyph) {
      LineGlyph.home => Stickers.home,
      LineGlyph.profile => Stickers.profile,
      LineGlyph.bell ||
      LineGlyph.bellRing ||
      LineGlyph.mail => Stickers.notification,
      LineGlyph.personAdd => Stickers.addFriend,
      LineGlyph.users => Stickers.friends,
      LineGlyph.card ||
      LineGlyph.cardAdd ||
      LineGlyph.contactless => Stickers.card,
      LineGlyph.coins || LineGlyph.sparkleCoin => Stickers.coins,
      LineGlyph.ardCoin => Stickers.coin,
      LineGlyph.trend || LineGlyph.sprout || LineGlyph.chart => Stickers.growth,
      LineGlyph.crown ||
      LineGlyph.trophy ||
      LineGlyph.star ||
      LineGlyph.checkCircle => Stickers.success,
      LineGlyph.wallet ||
      LineGlyph.banknote ||
      LineGlyph.bag ||
      LineGlyph.shirt ||
      LineGlyph.percent => Stickers.payment,
      LineGlyph.camera => Stickers.avatar,
      LineGlyph.pocket => Stickers.jar,
      LineGlyph.receipt || LineGlyph.history => Stickers.report,
      LineGlyph.piggy || LineGlyph.bank => Stickers.piggy,
      LineGlyph.gift => Stickers.gift,
      LineGlyph.paperPlane => Stickers.transfer,
      LineGlyph.charge => Stickers.receive,
      LineGlyph.lock ||
      LineGlyph.fingerprint ||
      LineGlyph.faceId ||
      LineGlyph.phone => Stickers.lock,
      LineGlyph.shield => Stickers.shield,
      LineGlyph.target => Stickers.goal,
      LineGlyph.calculator => Stickers.calculator,
      LineGlyph.link => Stickers.family,
      LineGlyph.food => Stickers.snack,
      LineGlyph.bus || LineGlyph.plane => Stickers.travel,
      LineGlyph.gamepad => Stickers.games,
      LineGlyph.book => Stickers.books,
      LineGlyph.graduation => Stickers.study,
      LineGlyph.heart => Stickers.love,
      LineGlyph.qr || LineGlyph.scan => Stickers.qr,
      LineGlyph.edit => Stickers.edit,
      LineGlyph.palette => Stickers.art,
      LineGlyph.ball => Stickers.sports,
      _ => null,
    };
  }

  /// Below this a sticker is too small to read, so the line stays.
  static const _stickerMin = 18.0;

  @override
  Widget build(BuildContext context) {
    final sticker = PlainLineIcons.of(context)
        ? null
        : kidsSticker(glyph, size);
    final icon = SizedBox.square(
      dimension: size,
      child: sticker == null
          ? CustomPaint(painter: _LinePainter(glyph, color, stroke))
          // A cut-out character has air around it, so it's drawn a little
          // larger than the glyph's box (which keeps the layout unchanged).
          : OverflowBox(
              maxWidth: size * 1.45,
              maxHeight: size * 1.45,
              child: Image.asset(
                sticker,
                width: size * 1.45,
                height: size * 1.45,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, _, _) =>
                    CustomPaint(painter: _LinePainter(glyph, color, stroke)),
              ),
            ),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: icon);
    return Semantics(label: semanticLabel, child: icon);
  }
}

/// Keeps every [LineIcon] below it a line, even under 10 where icons
/// otherwise become the companion's stickers (the sign-in and auth screens).
class PlainLineIcons extends InheritedWidget {
  const PlainLineIcons({super.key, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PlainLineIcons>() != null;

  @override
  bool updateShouldNotify(PlainLineIcons oldWidget) => false;
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

  static RRect _rr(double l, double t, double w, double h, double r) =>
      RRect.fromRectAndRadius(_r(l, t, w, h), Radius.circular(r));

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
      case LineGlyph.check:
        p
          ..moveTo(5, 12.5)
          ..lineTo(9.5, 17)
          ..lineTo(19, 7.5);
      case LineGlyph.checkCircle:
        _circle(p, 12, 12, 8.5);
        p
          ..moveTo(8.2, 12.3)
          ..lineTo(10.8, 14.8)
          ..lineTo(15.8, 9.5);
      case LineGlyph.alert:
        p
          ..moveTo(12, 4)
          ..lineTo(21, 19.5)
          ..lineTo(3, 19.5)
          ..close()
          ..moveTo(12, 10)
          ..lineTo(12, 13.8);
        _dot(p, 12, 16.6);
      case LineGlyph.lock:
        p
          ..addRRect(_rr(5, 10.5, 14, 10, 2.5))
          ..moveTo(8, 10.5)
          ..lineTo(8, 7.5)
          ..cubicTo(8, 5.3, 9.8, 3.5, 12, 3.5)
          ..cubicTo(14.2, 3.5, 16, 5.3, 16, 7.5)
          ..lineTo(16, 10.5)
          ..moveTo(12, 14.5)
          ..lineTo(12, 16.5);
      case LineGlyph.shield:
        p
          ..moveTo(12, 3.5)
          ..lineTo(19, 6.2)
          ..lineTo(19, 11.5)
          ..cubicTo(19, 15.8, 16.1, 19.1, 12, 20.5)
          ..cubicTo(7.9, 19.1, 5, 15.8, 5, 11.5)
          ..lineTo(5, 6.2)
          ..close()
          ..moveTo(9, 12)
          ..lineTo(11.2, 14.2)
          ..lineTo(15.2, 10);
      case LineGlyph.fingerprint:
        p
          ..moveTo(6.3, 17.5)
          ..cubicTo(5.5, 15.8, 5, 13.9, 5, 12)
          ..cubicTo(5, 8.1, 8.1, 5, 12, 5)
          ..cubicTo(14.2, 5, 16.1, 6, 17.4, 7.5)
          ..moveTo(18.6, 10)
          ..cubicTo(18.9, 10.6, 19, 11.3, 19, 12)
          ..lineTo(19, 13)
          ..moveTo(9, 19.5)
          ..cubicTo(8.4, 17.3, 8.5, 14.7, 8.5, 12)
          ..cubicTo(8.5, 10.1, 10.1, 8.5, 12, 8.5)
          ..cubicTo(13.9, 8.5, 15.5, 10.1, 15.5, 12)
          ..cubicTo(15.5, 14.6, 15.1, 17, 14.4, 19.5)
          ..moveTo(12, 12)
          ..cubicTo(12, 15, 11.8, 17.7, 11.8, 20.5);
      case LineGlyph.faceId:
        p
          ..moveTo(4, 8.5)
          ..lineTo(4, 6.5)
          ..quadraticBezierTo(4, 4, 6.5, 4)
          ..lineTo(8.5, 4)
          ..moveTo(15.5, 4)
          ..lineTo(17.5, 4)
          ..quadraticBezierTo(20, 4, 20, 6.5)
          ..lineTo(20, 8.5)
          ..moveTo(20, 15.5)
          ..lineTo(20, 17.5)
          ..quadraticBezierTo(20, 20, 17.5, 20)
          ..lineTo(15.5, 20)
          ..moveTo(8.5, 20)
          ..lineTo(6.5, 20)
          ..quadraticBezierTo(4, 20, 4, 17.5)
          ..lineTo(4, 15.5)
          ..moveTo(9, 9.5)
          ..lineTo(9, 10.5)
          ..moveTo(15, 9.5)
          ..lineTo(15, 10.5)
          ..moveTo(12, 9.5)
          ..lineTo(12, 13)
          ..lineTo(11, 13)
          ..moveTo(9.2, 15.5)
          ..quadraticBezierTo(12, 17.5, 14.8, 15.5);
      case LineGlyph.phone:
        p
          ..addRRect(_rr(6.5, 3, 11, 18, 2.5))
          ..moveTo(10.5, 18)
          ..lineTo(13.5, 18);
      case LineGlyph.target:
        _circle(p, 12, 12, 8.5);
        _circle(p, 12, 12, 5);
        _dot(p, 12, 12);
      case LineGlyph.calendar:
        p
          ..addRRect(_rr(4, 5.5, 16, 15, 2.5))
          ..moveTo(4, 10)
          ..lineTo(20, 10)
          ..moveTo(8.5, 3.5)
          ..lineTo(8.5, 7)
          ..moveTo(15.5, 3.5)
          ..lineTo(15.5, 7);
      case LineGlyph.chart:
        p
          ..moveTo(4, 20)
          ..lineTo(20, 20)
          ..moveTo(7, 16.5)
          ..lineTo(7, 12)
          ..moveTo(12, 16.5)
          ..lineTo(12, 6)
          ..moveTo(17, 16.5)
          ..lineTo(17, 9.5);
      case LineGlyph.calculator:
        p
          ..addRRect(_rr(5, 3, 14, 18, 2.5))
          ..addRRect(_rr(8, 6, 8, 3.5, 1));
        _dot(p, 9, 13);
        _dot(p, 12, 13);
        _dot(p, 15, 13);
        _dot(p, 9, 17);
        _dot(p, 12, 17);
        _dot(p, 15, 17);
      case LineGlyph.users:
        _circle(p, 9, 8.5, 3.2);
        p
          ..moveTo(3, 19.5)
          ..cubicTo(3, 16.2, 5.6, 14, 9, 14)
          ..cubicTo(12.4, 14, 15, 16.2, 15, 19.5)
          ..moveTo(15.5, 5.6)
          ..cubicTo(17.2, 5.9, 18.5, 7.3, 18.5, 9)
          ..cubicTo(18.5, 10.7, 17.2, 12.1, 15.5, 12.4)
          ..moveTo(17.5, 14.4)
          ..cubicTo(19.6, 15.1, 21, 17, 21, 19.5);
      case LineGlyph.link:
        p
          ..moveTo(10.5, 13.5)
          ..cubicTo(11.6, 14.9, 13.6, 15.1, 14.9, 13.8)
          ..lineTo(17.8, 10.9)
          ..cubicTo(19.1, 9.6, 19.1, 7.5, 17.8, 6.2)
          ..cubicTo(16.5, 4.9, 14.4, 4.9, 13.1, 6.2)
          ..lineTo(12, 7.3)
          ..moveTo(13.5, 10.5)
          ..cubicTo(12.4, 9.1, 10.4, 8.9, 9.1, 10.2)
          ..lineTo(6.2, 13.1)
          ..cubicTo(4.9, 14.4, 4.9, 16.5, 6.2, 17.8)
          ..cubicTo(7.5, 19.1, 9.6, 19.1, 10.9, 17.8)
          ..lineTo(12, 16.7);
      case LineGlyph.food:
        p
          ..moveTo(7, 3.5)
          ..lineTo(7, 20.5)
          ..moveTo(4.5, 3.5)
          ..lineTo(4.5, 8)
          ..cubicTo(4.5, 9.4, 5.6, 10.5, 7, 10.5)
          ..cubicTo(8.4, 10.5, 9.5, 9.4, 9.5, 8)
          ..lineTo(9.5, 3.5)
          ..moveTo(17, 20.5)
          ..lineTo(17, 3.5)
          ..cubicTo(14.8, 4.5, 14, 7.5, 14, 10)
          ..lineTo(14, 13)
          ..lineTo(17, 13);
      case LineGlyph.bus:
        p
          ..addRRect(_rr(5, 3.5, 14, 14, 3))
          ..moveTo(5, 11)
          ..lineTo(19, 11)
          ..moveTo(7.5, 17.5)
          ..lineTo(7.5, 20)
          ..moveTo(16.5, 17.5)
          ..lineTo(16.5, 20);
        _dot(p, 8.5, 14.3);
        _dot(p, 15.5, 14.3);
      case LineGlyph.shirt:
        p
          ..moveTo(9, 4)
          ..quadraticBezierTo(12, 6.5, 15, 4)
          ..lineTo(20.5, 7)
          ..lineTo(18.5, 11)
          ..lineTo(17, 10.3)
          ..lineTo(17, 20)
          ..lineTo(7, 20)
          ..lineTo(7, 10.3)
          ..lineTo(5.5, 11)
          ..lineTo(3.5, 7)
          ..close();
      case LineGlyph.gamepad:
        p
          ..moveTo(8, 7)
          ..lineTo(16, 7)
          ..cubicTo(19, 7, 21, 9.5, 21, 13)
          ..cubicTo(21, 16, 19.8, 17.5, 18.4, 17.5)
          ..cubicTo(16.5, 17.5, 16, 15, 14.5, 15)
          ..lineTo(9.5, 15)
          ..cubicTo(8, 15, 7.5, 17.5, 5.6, 17.5)
          ..cubicTo(4.2, 17.5, 3, 16, 3, 13)
          ..cubicTo(3, 9.5, 5, 7, 8, 7)
          ..close()
          ..moveTo(8, 9.5)
          ..lineTo(8, 12.5)
          ..moveTo(6.5, 11)
          ..lineTo(9.5, 11);
        _dot(p, 15.5, 10.3);
        _dot(p, 17, 12);
      case LineGlyph.book:
        p
          ..moveTo(12, 6.5)
          ..cubicTo(10.2, 5.2, 7.5, 4.8, 4, 5)
          ..lineTo(4, 18)
          ..cubicTo(7.5, 17.8, 10.2, 18.2, 12, 19.5)
          ..cubicTo(13.8, 18.2, 16.5, 17.8, 20, 18)
          ..lineTo(20, 5)
          ..cubicTo(16.5, 4.8, 13.8, 5.2, 12, 6.5)
          ..close()
          ..moveTo(12, 6.5)
          ..lineTo(12, 19.5);
      case LineGlyph.bag:
        p
          ..moveTo(5.5, 8)
          ..lineTo(18.5, 8)
          ..lineTo(19.5, 20)
          ..lineTo(4.5, 20)
          ..close()
          ..moveTo(9, 10.5)
          ..lineTo(9, 7)
          ..cubicTo(9, 5.3, 10.3, 4, 12, 4)
          ..cubicTo(13.7, 4, 15, 5.3, 15, 7)
          ..lineTo(15, 10.5);
      case LineGlyph.star:
        p
          ..moveTo(12, 3.8)
          ..lineTo(14.5, 9)
          ..lineTo(20.2, 9.7)
          ..lineTo(16, 13.6)
          ..lineTo(17.1, 19.3)
          ..lineTo(12, 16.5)
          ..lineTo(6.9, 19.3)
          ..lineTo(8, 13.6)
          ..lineTo(3.8, 9.7)
          ..lineTo(9.5, 9)
          ..close();
      case LineGlyph.heart:
        p
          ..moveTo(12, 19.5)
          ..cubicTo(6.5, 16, 3.5, 12.8, 3.5, 9.3)
          ..cubicTo(3.5, 6.6, 5.6, 4.8, 8, 4.8)
          ..cubicTo(9.7, 4.8, 11.2, 5.8, 12, 7.3)
          ..cubicTo(12.8, 5.8, 14.3, 4.8, 16, 4.8)
          ..cubicTo(18.4, 4.8, 20.5, 6.6, 20.5, 9.3)
          ..cubicTo(20.5, 12.8, 17.5, 16, 12, 19.5)
          ..close();
      case LineGlyph.qr:
        p
          ..addRRect(_rr(4, 4, 6.5, 6.5, 1.5))
          ..addRRect(_rr(13.5, 4, 6.5, 6.5, 1.5))
          ..addRRect(_rr(4, 13.5, 6.5, 6.5, 1.5))
          ..moveTo(13.5, 13.5)
          ..lineTo(16, 13.5)
          ..moveTo(19.5, 13.5)
          ..lineTo(20, 13.5)
          ..moveTo(13.5, 17)
          ..lineTo(13.5, 20)
          ..moveTo(17, 17)
          ..lineTo(20, 17)
          ..lineTo(20, 20)
          ..lineTo(17, 20);
      case LineGlyph.bank:
        p
          ..moveTo(3.5, 9)
          ..lineTo(12, 4)
          ..lineTo(20.5, 9)
          ..close()
          ..moveTo(6, 11.5)
          ..lineTo(6, 17)
          ..moveTo(10, 11.5)
          ..lineTo(10, 17)
          ..moveTo(14, 11.5)
          ..lineTo(14, 17)
          ..moveTo(18, 11.5)
          ..lineTo(18, 17)
          ..moveTo(3.5, 20)
          ..lineTo(20.5, 20);
      case LineGlyph.edit:
        p
          ..moveTo(4.5, 19.5)
          ..lineTo(5, 15.5)
          ..lineTo(15.5, 5)
          ..cubicTo(16.3, 4.2, 17.7, 4.2, 18.5, 5)
          ..lineTo(19, 5.5)
          ..cubicTo(19.8, 6.3, 19.8, 7.7, 19, 8.5)
          ..lineTo(8.5, 19)
          ..close()
          ..moveTo(13.5, 7)
          ..lineTo(17, 10.5);
      case LineGlyph.logout:
        p
          ..moveTo(10, 4.5)
          ..lineTo(6.5, 4.5)
          ..quadraticBezierTo(4.5, 4.5, 4.5, 6.5)
          ..lineTo(4.5, 17.5)
          ..quadraticBezierTo(4.5, 19.5, 6.5, 19.5)
          ..lineTo(10, 19.5)
          ..moveTo(10, 12)
          ..lineTo(20, 12)
          ..moveTo(16.5, 8.5)
          ..lineTo(20, 12)
          ..lineTo(16.5, 15.5);
      case LineGlyph.help:
        _circle(p, 12, 12, 8.5);
        p
          ..moveTo(9.6, 9.6)
          ..cubicTo(9.6, 8.3, 10.7, 7.4, 12, 7.4)
          ..cubicTo(13.3, 7.4, 14.4, 8.3, 14.4, 9.6)
          ..cubicTo(14.4, 11.4, 12, 11.5, 12, 13.3);
        _dot(p, 12, 16.3);
      case LineGlyph.moon:
        p
          ..moveTo(19.5, 14.5)
          ..cubicTo(18.4, 15, 17.2, 15.2, 16, 15.2)
          ..cubicTo(11.6, 15.2, 8.3, 11.9, 8.3, 7.5)
          ..cubicTo(8.3, 6.3, 8.5, 5.1, 9, 4.1)
          ..cubicTo(5.8, 5.3, 3.5, 8.4, 3.5, 12)
          ..cubicTo(3.5, 16.7, 7.3, 20.5, 12, 20.5)
          ..cubicTo(15.4, 20.5, 18.3, 18.4, 19.5, 14.5)
          ..close();
      case LineGlyph.sun:
        _circle(p, 12, 12, 4);
        for (final (dx, dy) in const [
          (0.0, -1.0),
          (0.0, 1.0),
          (-1.0, 0.0),
          (1.0, 0.0),
          (0.707, 0.707),
          (-0.707, 0.707),
          (0.707, -0.707),
          (-0.707, -0.707),
        ]) {
          p
            ..moveTo(12 + dx * 6.8, 12 + dy * 6.8)
            ..lineTo(12 + dx * 8.8, 12 + dy * 8.8);
        }
      case LineGlyph.palette:
        p
          ..moveTo(12, 20.5)
          ..cubicTo(7.3, 20.5, 3.5, 16.7, 3.5, 12)
          ..cubicTo(3.5, 7.3, 7.3, 3.5, 12, 3.5)
          ..cubicTo(16.7, 3.5, 20.5, 6.9, 20.5, 11)
          ..cubicTo(20.5, 13.5, 18.5, 15, 16.5, 15)
          ..lineTo(14.8, 15)
          ..cubicTo(13.8, 15, 13.2, 16, 13.6, 16.9)
          ..cubicTo(14.2, 18.4, 13.6, 20.5, 12, 20.5)
          ..close();
        _dot(p, 8, 11.5);
        _dot(p, 10.5, 7.8);
        _dot(p, 14.8, 8);
      case LineGlyph.graduation:
        p
          ..moveTo(2.5, 9.5)
          ..lineTo(12, 5)
          ..lineTo(21.5, 9.5)
          ..lineTo(12, 14)
          ..close()
          ..moveTo(6.5, 11.5)
          ..lineTo(6.5, 16)
          ..cubicTo(9.5, 18.8, 14.5, 18.8, 17.5, 16)
          ..lineTo(17.5, 11.5)
          ..moveTo(21.5, 9.5)
          ..lineTo(21.5, 14);
      case LineGlyph.trophy:
        p
          ..moveTo(7.5, 4.5)
          ..lineTo(16.5, 4.5)
          ..lineTo(16.5, 10)
          ..cubicTo(16.5, 12.5, 14.5, 14.5, 12, 14.5)
          ..cubicTo(9.5, 14.5, 7.5, 12.5, 7.5, 10)
          ..close()
          ..moveTo(7.5, 6.5)
          ..lineTo(4.5, 6.5)
          ..lineTo(4.5, 8)
          ..cubicTo(4.5, 9.7, 5.8, 11, 7.6, 11)
          ..moveTo(16.5, 6.5)
          ..lineTo(19.5, 6.5)
          ..lineTo(19.5, 8)
          ..cubicTo(19.5, 9.7, 18.2, 11, 16.4, 11)
          ..moveTo(12, 14.5)
          ..lineTo(12, 17.5)
          ..moveTo(8.5, 20)
          ..lineTo(15.5, 20)
          ..lineTo(15, 17.5)
          ..lineTo(9, 17.5)
          ..close();
      case LineGlyph.percent:
        p
          ..moveTo(18.5, 5.5)
          ..lineTo(5.5, 18.5);
        _circle(p, 7.5, 7.5, 2.3);
        _circle(p, 16.5, 16.5, 2.3);
      case LineGlyph.snowflake:
        for (final (dx, dy) in const [
          (0.0, 1.0),
          (0.866, 0.5),
          (0.866, -0.5),
        ]) {
          p
            ..moveTo(12 - dx * 8.5, 12 - dy * 8.5)
            ..lineTo(12 + dx * 8.5, 12 + dy * 8.5);
        }
        for (final a in const [
          (0.0, 1.0),
          (0.0, -1.0),
          (0.866, 0.5),
          (-0.866, -0.5),
          (0.866, -0.5),
          (-0.866, 0.5),
        ]) {
          final (dx, dy) = a;
          final bx = 12 + dx * 6, by = 12 + dy * 6;
          p
            ..moveTo(bx - dy * 2.2 - dx * 1.6, by + dx * 2.2 - dy * 1.6)
            ..lineTo(bx, by)
            ..lineTo(bx + dy * 2.2 - dx * 1.6, by - dx * 2.2 - dy * 1.6);
        }
      case LineGlyph.search:
        _circle(p, 10.8, 10.8, 6.3);
        p
          ..moveTo(15.4, 15.4)
          ..lineTo(20, 20);
      case LineGlyph.mail:
        p
          ..addRRect(_rr(3.5, 5.5, 17, 13, 2.5))
          ..moveTo(4.5, 7)
          ..lineTo(12, 12.5)
          ..lineTo(19.5, 7);
      case LineGlyph.camera:
        p
          ..moveTo(4, 8.5)
          ..quadraticBezierTo(4, 7, 5.5, 7)
          ..lineTo(8, 7)
          ..lineTo(9.5, 4.5)
          ..lineTo(14.5, 4.5)
          ..lineTo(16, 7)
          ..lineTo(18.5, 7)
          ..quadraticBezierTo(20, 7, 20, 8.5)
          ..lineTo(20, 18)
          ..quadraticBezierTo(20, 19.5, 18.5, 19.5)
          ..lineTo(5.5, 19.5)
          ..quadraticBezierTo(4, 19.5, 4, 18)
          ..close();
        _circle(p, 12, 13, 3.3);
      case LineGlyph.ball:
        _circle(p, 12, 12, 8.5);
        p
          ..moveTo(3.5, 12)
          ..lineTo(20.5, 12)
          ..moveTo(12, 3.5)
          ..cubicTo(9.5, 6, 9.5, 18, 12, 20.5)
          ..moveTo(12, 3.5)
          ..cubicTo(14.5, 6, 14.5, 18, 12, 20.5);
      case LineGlyph.plane:
        p
          ..moveTo(10.2, 13.8)
          ..lineTo(4, 11.5)
          ..lineTo(5.5, 10)
          ..lineTo(11.8, 10.6)
          ..lineTo(16.2, 6.2)
          ..cubicTo(17.2, 5.2, 18.8, 5.2, 18.8, 5.2)
          ..cubicTo(18.8, 5.2, 18.8, 6.8, 17.8, 7.8)
          ..lineTo(13.4, 12.2)
          ..lineTo(14, 18.5)
          ..lineTo(12.5, 20)
          ..lineTo(10.2, 13.8)
          ..moveTo(7.5, 15.5)
          ..lineTo(5, 18)
          ..moveTo(8.5, 16.5)
          ..lineTo(6, 19);
      case LineGlyph.history:
        p
          ..moveTo(4, 12)
          ..cubicTo(4, 7.6, 7.6, 4, 12, 4)
          ..cubicTo(16.4, 4, 20, 7.6, 20, 12)
          ..cubicTo(20, 16.4, 16.4, 20, 12, 20)
          ..cubicTo(9.2, 20, 6.8, 18.6, 5.3, 16.4)
          ..moveTo(4, 7.5)
          ..lineTo(4, 12)
          ..lineTo(8.5, 12)
          ..moveTo(12, 8)
          ..lineTo(12, 12)
          ..lineTo(14.8, 14.3);
      case LineGlyph.minus:
        p
          ..moveTo(5.5, 12)
          ..lineTo(18.5, 12);
      case LineGlyph.chevronLeft:
        p
          ..moveTo(14.5, 6)
          ..lineTo(8.5, 12)
          ..lineTo(14.5, 18);
    }
    return p;
  }
}
