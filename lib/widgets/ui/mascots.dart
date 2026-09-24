/// Mascot and companion-sticker assets and the widgets that show them.
library;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../app_text.dart';
import '../common.dart';

/// A small animal sticker used in place of an emoji: the mascot inside a
/// white circle, so it reads the same on white, tinted and filled surfaces.
class MascotIcon extends StatelessWidget {
  const MascotIcon(this.asset, {super.key, this.size = 22, this.label = ''});

  final String asset;
  final double size;

  /// Semantic label; empty when the text next to it already says it all.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: MascotImage(
          asset: asset,
          size: size,
          background: Colors.white,
          semanticLabel: label,
        ),
      ),
    );
  }
}

/// Mascot tile: sticker image inside a rounded tinted square.
class MascotTile extends StatelessWidget {
  const MascotTile({
    super.key,
    required this.asset,
    this.size = 48,
    this.background = Colors.white,
    this.radius = 16,
    this.border,
    this.label = '',
  });

  final String asset;
  final double size;
  final Color background;
  final double radius;
  final Color? border;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.06),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: border == null ? null : Border.all(color: border!),
      ),
      child: MascotImage(
        asset: asset,
        size: size,
        background: background,
        semanticLabel: label,
      ),
    );
  }
}

/// Circular avatar with initials, used for people without a photo.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.background,
    this.foreground,
    this.square = false,
  });

  final String name;
  final double size;

  /// Default to the theme accent (`AppColors.sky100`/`sky700`).
  final Color? background;
  final Color? foreground;
  final bool square;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? AppColors.sky100,
        shape: square ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: square ? BorderRadius.circular(size * 0.32) : null,
      ),
      child: AppText(
        trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase(),
        size: size * 0.4,
        weight: FontWeight.w700,
        color: foreground ?? AppColors.sky700,
      ),
    );
  }
}

/// Mascot asset paths.
abstract final class Mascots {
  static const _d = 'assets/images';
  static const bearCard = '$_d/mascot_bear_card.jpg';
  static const foxPhone = '$_d/mascot_fox_phone.jpg';
  static const bunnyBattery = '$_d/mascot_bunny_battery.jpg';
  static const penguinChecklist = '$_d/mascot_penguin_checklist.jpg';
  static const owlBook = '$_d/mascot_owl_book.jpg';
  static const sleepingCat = '$_d/mascot_sleeping_cat.jpg';
  static const bearStar = '$_d/mascot_bear_star.jpg';
  static const puppyPiggy = '$_d/mascot_puppy_piggy.jpg';
  static const puppyGamepad = '$_d/mascot_puppy_gamepad.jpg';
  static const catHeart = '$_d/mascot_cat_heart.jpg';
  static const bearBooks = '$_d/mascot_bear_books.jpg';
  static const bearConfetti = '$_d/mascot_bear_confetti.jpg';
  static const owlAbacus = '$_d/mascot_owl_abacus.jpg';
  static const bearFamily = '$_d/mascot_bear_family.jpg';
  static const foxWave = '$_d/mascot_fox_wave.jpg';
  static const redPandaTrophy = '$_d/mascot_red_panda_trophy.jpg';
  static const pandaMilk = '$_d/mascot_panda_milk.jpg';
  static const pandaPiggy = '$_d/mascot_panda_piggy.jpg';
  static const hedgehogPiggy = '$_d/mascot_hedgehog_piggy.jpg';
  static const squirrelSafe = '$_d/mascot_squirrel_safe.jpg';
  static const bearShield = '$_d/mascot_bear_shield.jpg';
  static const studentCard = '$_d/student_card.jpg';
  static const otterInvest = '$_d/mascot_otter_invest.jpg';
  static const redPandaLetter = '$_d/mascot_red_panda_letter.jpg';
  static const foxBlocks = '$_d/mascot_fox_blocks.jpg';
  static const catNotes = '$_d/mascot_cat_notes.jpg';
  static const bunnyCoin = '$_d/mascot_bunny_coin.jpg';
  static const shieldBadge = '$_d/shield_badge.jpg';
  static const bearSitting = '$_d/mascot_bear_sitting.jpg';
  static const owlMedal = '$_d/mascot_owl_medal.jpg';
  static const bunnyTooth = '$_d/mascot_bunny_tooth.jpg';
  static const lambShield = '$_d/mascot_lamb_shield.jpg';
  static const penguinList = '$_d/mascot_penguin_list.jpg';
  static const bearFund = '$_d/mascot_bear_fund.jpg';
  static const bearHugCoin = '$_d/mascot_bear_hug_coin.jpg';
  static const foxJump = '$_d/mascot_fox_jump.jpg';
  static const fox = '$_d/mascot_fox.jpg';
  static const redPanda = '$_d/mascot_red_panda.jpg';

  /// [redPanda] cut out onto a transparent background.
  static const redPandaCutout = '$_d/mascot_red_panda_cutout.png';
  static const pandaKey = '$_d/mascot_panda_key.png';
}

/// The fox companion's sticker set, cut from one sheet onto a transparent
/// background. Unlike the [Mascots] JPEGs these need no multiply blend, so
/// [MascotImage] leaves PNGs alone.
abstract final class FoxStickers {
  static const _d = 'assets/images';
  static const addFriend = '$_d/fox/fox_add_friend.png';
  static const avatar = '$_d/fox/fox_avatar.png';
  static const calculator = '$_d/fox/fox_calculator.png';
  static const card = '$_d/fox/fox_card.png';
  static const coin = '$_d/fox/fox_coin.png';
  static const coins = '$_d/fox/fox_coins.png';
  static const contacts = '$_d/fox/fox_contacts.png';
  static const edit = '$_d/fox/fox_edit.png';
  static const family = '$_d/fox/fox_family.png';
  static const friends = '$_d/fox/fox_friends.png';
  static const gift = '$_d/fox/fox_gift.png';
  static const goal = '$_d/fox/fox_goal.png';
  static const growth = '$_d/fox/fox_growth.png';
  static const home = '$_d/fox/fox_home.png';
  static const jar = '$_d/fox/fox_jar.png';
  static const notification = '$_d/fox/fox_notification.png';
  static const piggy = '$_d/fox/fox_piggy.png';
  static const profile = '$_d/fox/fox_profile.png';
  static const receive = '$_d/fox/fox_receive.png';
  static const report = '$_d/fox/fox_report.png';
  static const shield = '$_d/fox/fox_shield.png';
  static const success = '$_d/fox/fox_success.png';
  static const transfer = '$_d/fox/fox_transfer.png';
}

/// The bear companion's sticker set, cut from a sheet drawn to match
/// [FoxStickers] (same names, same poses).
abstract final class BearStickers {
  static const _d = 'assets/images';
  static const addFriend = '$_d/bear/bear_add_friend.png';
  static const avatar = '$_d/bear/bear_avatar.png';
  static const calculator = '$_d/bear/bear_calculator.png';
  static const card = '$_d/bear/bear_card.png';
  static const coin = '$_d/bear/bear_coin.png';
  static const coins = '$_d/bear/bear_coins.png';
  static const contacts = '$_d/bear/bear_contacts.png';
  static const edit = '$_d/bear/bear_edit.png';
  static const family = '$_d/bear/bear_family.png';
  static const friends = '$_d/bear/bear_friends.png';
  static const gift = '$_d/bear/bear_gift.png';
  static const goal = '$_d/bear/bear_goal.png';
  static const growth = '$_d/bear/bear_growth.png';
  static const home = '$_d/bear/bear_home.png';
  static const jar = '$_d/bear/bear_jar.png';
  static const notification = '$_d/bear/bear_notification.png';
  static const piggy = '$_d/bear/bear_piggy.png';
  static const profile = '$_d/bear/bear_profile.png';
  static const receive = '$_d/bear/bear_receive.png';
  static const report = '$_d/bear/bear_report.png';
  static const shield = '$_d/bear/bear_shield.png';
  static const success = '$_d/bear/bear_success.png';
  static const transfer = '$_d/bear/bear_transfer.png';
}

/// The rabbit (bunny) companion's sticker set, drawn to match
/// [FoxStickers] (same names, same poses).
abstract final class RabbitStickers {
  static const _d = 'assets/images';
  static const addFriend = '$_d/rabbit/rabbit_add_friend.png';
  static const avatar = '$_d/rabbit/rabbit_avatar.png';
  static const calculator = '$_d/rabbit/rabbit_calculator.png';
  static const card = '$_d/rabbit/rabbit_card.png';
  static const coin = '$_d/rabbit/rabbit_coin.png';
  static const coins = '$_d/rabbit/rabbit_coins.png';
  static const contacts = '$_d/rabbit/rabbit_contacts.png';
  static const edit = '$_d/rabbit/rabbit_edit.png';
  static const family = '$_d/rabbit/rabbit_family.png';
  static const friends = '$_d/rabbit/rabbit_friends.png';
  static const gift = '$_d/rabbit/rabbit_gift.png';
  static const goal = '$_d/rabbit/rabbit_goal.png';
  static const growth = '$_d/rabbit/rabbit_growth.png';
  static const home = '$_d/rabbit/rabbit_home.png';
  static const jar = '$_d/rabbit/rabbit_jar.png';
  static const notification = '$_d/rabbit/rabbit_notification.png';
  static const piggy = '$_d/rabbit/rabbit_piggy.png';
  static const profile = '$_d/rabbit/rabbit_profile.png';
  static const receive = '$_d/rabbit/rabbit_receive.png';
  static const report = '$_d/rabbit/rabbit_report.png';
  static const shield = '$_d/rabbit/rabbit_shield.png';
  static const success = '$_d/rabbit/rabbit_success.png';
  static const transfer = '$_d/rabbit/rabbit_transfer.png';
}

/// The penguin companion's sticker set, drawn to match [FoxStickers]
/// (same names, same poses).
abstract final class PenguinStickers {
  static const _d = 'assets/images';
  static const addFriend = '$_d/penguin/penguin_add_friend.png';
  static const avatar = '$_d/penguin/penguin_avatar.png';
  static const calculator = '$_d/penguin/penguin_calculator.png';
  static const card = '$_d/penguin/penguin_card.png';
  static const coin = '$_d/penguin/penguin_coin.png';
  static const coins = '$_d/penguin/penguin_coins.png';
  static const contacts = '$_d/penguin/penguin_contacts.png';
  static const edit = '$_d/penguin/penguin_edit.png';
  static const family = '$_d/penguin/penguin_family.png';
  static const friends = '$_d/penguin/penguin_friends.png';
  static const gift = '$_d/penguin/penguin_gift.png';
  static const goal = '$_d/penguin/penguin_goal.png';
  static const growth = '$_d/penguin/penguin_growth.png';
  static const home = '$_d/penguin/penguin_home.png';
  static const jar = '$_d/penguin/penguin_jar.png';
  static const notification = '$_d/penguin/penguin_notification.png';
  static const piggy = '$_d/penguin/penguin_piggy.png';
  static const profile = '$_d/penguin/penguin_profile.png';
  static const receive = '$_d/penguin/penguin_receive.png';
  static const report = '$_d/penguin/penguin_report.png';
  static const shield = '$_d/penguin/penguin_shield.png';
  static const success = '$_d/penguin/penguin_success.png';
  static const transfer = '$_d/penguin/penguin_transfer.png';
}
