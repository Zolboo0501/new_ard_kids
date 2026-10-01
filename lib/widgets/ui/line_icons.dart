import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../app/age_group.dart';
import '../../app/avatar.dart';

/// The app's icons: one outline family, Iconsax Outline (`iconsax_flutter`,
/// whose `_copy` names are the outline style), picked by what the icon
/// means so screens don't depend on the icon font's names. Pick a glyph and
/// a colour.
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

  /// Kept so existing callers still build; Iconsax draws its own stroke.
  final double stroke;

  /// Each glyph's Iconsax Outline icon.
  static IconData iconFor(LineGlyph glyph) => switch (glyph) {
    LineGlyph.eye => Iconsax.eye_copy,
    LineGlyph.eyeOff => Iconsax.eye_slash_copy,
    LineGlyph.home => Iconsax.home_2_copy,
    LineGlyph.profile => Iconsax.user_copy,
    LineGlyph.scan => Iconsax.scan_copy,
    LineGlyph.bell => Iconsax.notification_copy,
    LineGlyph.bellRing => Iconsax.notification_bing_copy,
    LineGlyph.settings => Iconsax.setting_2_copy,
    LineGlyph.arrowUpRight => Iconsax.arrow_up_1_copy,
    LineGlyph.arrowDownLeft => Iconsax.arrow_down_2_copy,
    LineGlyph.arrowRight => Iconsax.arrow_right_1_copy,
    LineGlyph.chevronRight => Iconsax.arrow_right_3_copy,
    LineGlyph.plus => Iconsax.add_copy,
    LineGlyph.close => Iconsax.add_copy,
    LineGlyph.personAdd => Iconsax.user_add_copy,
    LineGlyph.contactless => Iconsax.wifi_copy,
    LineGlyph.copy => Iconsax.copy_copy,
    LineGlyph.card => Iconsax.card_copy,
    LineGlyph.cardAdd => Iconsax.card_add_copy,
    LineGlyph.info => Iconsax.info_circle_copy,
    LineGlyph.clock => Iconsax.clock_copy,
    LineGlyph.flame => Iconsax.flash_1_copy,
    LineGlyph.bolt => Iconsax.flash_copy,
    LineGlyph.coins => Iconsax.coin_copy,
    LineGlyph.trend => Iconsax.trend_up_copy,
    LineGlyph.crown => Iconsax.crown_1_copy,
    LineGlyph.sparkleCoin => Iconsax.coin_1_copy,
    LineGlyph.wallet => Iconsax.wallet_2_copy,
    LineGlyph.receipt => Iconsax.receipt_2_copy,
    LineGlyph.plusCircle => Iconsax.add_circle_copy,
    LineGlyph.banknote => Iconsax.money_copy,
    LineGlyph.pocket => Iconsax.wallet_3_copy,
    LineGlyph.piggy => Iconsax.save_2_copy,
    LineGlyph.sprout => Iconsax.tree_copy,
    LineGlyph.gift => Iconsax.gift_copy,
    LineGlyph.ardCoin => Iconsax.coin_1_copy,
    LineGlyph.paperPlane => Iconsax.send_2_copy,
    LineGlyph.charge => Iconsax.battery_charging_copy,
    LineGlyph.check => Iconsax.check_copy,
    LineGlyph.checkCircle => Iconsax.tick_circle_copy,
    LineGlyph.alert => Iconsax.warning_2_copy,
    LineGlyph.lock => Iconsax.lock_copy,
    LineGlyph.shield => Iconsax.shield_tick_copy,
    LineGlyph.fingerprint => Iconsax.finger_scan_copy,
    LineGlyph.faceId => Iconsax.emoji_happy_copy,
    LineGlyph.phone => Iconsax.mobile_copy,
    LineGlyph.target => Iconsax.flag_copy,
    LineGlyph.calendar => Iconsax.calendar_copy,
    LineGlyph.chart => Iconsax.chart_copy,
    LineGlyph.calculator => Iconsax.calculator_copy,
    LineGlyph.users => Iconsax.people_copy,
    LineGlyph.link => Iconsax.link_copy,
    LineGlyph.food => Iconsax.cake_copy,
    LineGlyph.bus => Iconsax.bus_copy,
    LineGlyph.shirt => Iconsax.shopping_bag_copy,
    LineGlyph.gamepad => Iconsax.game_copy,
    LineGlyph.book => Iconsax.book_copy,
    LineGlyph.bag => Iconsax.bag_2_copy,
    LineGlyph.star => Iconsax.star_copy,
    LineGlyph.heart => Iconsax.heart_copy,
    LineGlyph.qr => Iconsax.scan_barcode_copy,
    LineGlyph.bank => Iconsax.bank_copy,
    LineGlyph.edit => Iconsax.edit_2_copy,
    LineGlyph.logout => Iconsax.logout_copy,
    LineGlyph.help => Iconsax.message_question_copy,
    LineGlyph.moon => Iconsax.moon_copy,
    LineGlyph.sun => Iconsax.sun_1_copy,
    LineGlyph.palette => Iconsax.brush_2_copy,
    LineGlyph.graduation => Iconsax.teacher_copy,
    LineGlyph.trophy => Iconsax.cup_copy,
    LineGlyph.percent => Iconsax.percentage_circle_copy,
    LineGlyph.snowflake => Iconsax.cloud_snow_copy,
    LineGlyph.search => Iconsax.search_normal_copy,
    LineGlyph.mail => Iconsax.sms_copy,
    LineGlyph.camera => Iconsax.camera_copy,
    LineGlyph.ball => Iconsax.weight_copy,
    LineGlyph.plane => Iconsax.airplane_copy,
    LineGlyph.history => Iconsax.refresh_copy,
    LineGlyph.minus => Iconsax.minus_copy,
    LineGlyph.chevronLeft => Iconsax.arrow_left_2_copy,
  };
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

  Widget _outline() {
    // Iconsax has no bare tick (its `check` is another symbol), so the
    // plain check is drawn in the same round 1.5 stroke.
    if (glyph == LineGlyph.check) {
      return SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _TickPainter(color)),
      );
    }
    final icon = Icon(iconFor(glyph), size: size, color: color);
    // Iconsax has no bare cross; its plus turned a quarter-circle is one.
    return glyph == LineGlyph.close
        ? Transform.rotate(angle: 0.785398, child: icon)
        : icon;
  }

  @override
  Widget build(BuildContext context) {
    final sticker = PlainLineIcons.of(context)
        ? null
        : kidsSticker(glyph, size);
    final icon = SizedBox.square(
      dimension: size,
      child: sticker == null
          ? _outline()
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
                errorBuilder: (_, _, _) => _outline(),
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

class _TickPainter extends CustomPainter {
  _TickPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.drawPath(
      Path()
        ..moveTo(5 * k, 12.5 * k)
        ..lineTo(9.75 * k, 17 * k)
        ..lineTo(19 * k, 7.5 * k),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_TickPainter old) => old.color != color;
}
