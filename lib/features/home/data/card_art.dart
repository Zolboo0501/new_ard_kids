import 'package:flutter/painting.dart';

import '../../../app/accounts.dart';
import '../../../app/age_group.dart';
import '../../../app/avatar.dart';
import '../../../theme/app_theme.dart';
import 'invoice.dart';

/// The chosen character's card art for an account on Home and the summary
/// cards, or null where the character has none (the plain card is drawn).
/// All four 10–13 characters (fox, rabbit, bear, cat) have sets, in
/// `assets/images/teenegars/<art>/cards/`; and all four under-10 cartoons
/// (fox, bear, rabbit, penguin) in `assets/images/kids/<set>/cards/`.
String? accountCardArt(String account) {
  final folder = switch (appAgeGroup.value) {
    AgeGroup.tween when _sets.contains(appAvatar.value.art) =>
      'teenegars/${appAvatar.value.art}',
    AgeGroup.under10 when _kidsSets.contains(appAvatar.value.stickerSet) =>
      'kids/${appAvatar.value.stickerSet}',
    _ => null,
  };
  if (folder == null) return null;
  final name = switch (account) {
    Accounts.main => 'main',
    Accounts.savings => 'savings',
    Accounts.stocks => 'stocks',
    Accounts.rewards => 'rewards',
    _ => 'coin',
  };
  return 'assets/images/$folder/cards/$name.webp';
}

/// The characters with a card set: 10–13 by art name, under 10 by sticker set.
const _sets = {'fox', 'rabbit', 'bear', 'cat'};
const _kidsSets = {'fox', 'bear', 'rabbit', 'penguin'};

/// The chosen character's banner behind an account row in Home's Данс list
/// (`AccountRow(background:)`), with the hue its glyph is set in and the
/// tint of the glyph's tile, or null where the character has none (the
/// plain row is drawn). All four under-10 cartoons have sets, in
/// `assets/images/kids/<set>/rows/{savings,stocks,rewards}.webp`; all
/// four 10–13 characters have them, in `assets/images/teenegars/<art>/rows/`.
({String asset, Color ink, Color tint})? accountRowArt(String account) {
  final avatar = appAvatar.value;
  final folder = switch (appAgeGroup.value) {
    AgeGroup.under10 when _kidsRowSets.contains(avatar.stickerSet) =>
      'kids/${avatar.stickerSet}',
    AgeGroup.tween when _teenRowSets.contains(avatar.art) =>
      'teenegars/${avatar.art}',
    _ => null,
  };
  if (folder == null) return null;
  final (name, ink, tint) = switch (account) {
    Accounts.savings => (
      'savings',
      const Color(0xFF1E3A8A),
      const Color(0xFFD6E8FF),
    ),
    Accounts.stocks => (
      'stocks',
      const Color(0xFF166534),
      const Color(0xFFD9F5DC),
    ),
    Accounts.rewards => (
      'rewards',
      const Color(0xFFBE123C),
      const Color(0xFFFFDDE4),
    ),
    _ => (null, null, null),
  };
  if (name == null) return null;
  return (
    asset: 'assets/images/$folder/rows/$name.webp',
    ink: ink!,
    tint: tint!,
  );
}

/// The characters with a row banner set: under 10 by sticker set, 10–13 by
/// art name.
const _kidsRowSets = {'fox', 'bear', 'rabbit', 'penguin'};
const _teenRowSets = {'fox', 'bear', 'cat', 'rabbit'};

/// The chosen character's art for one of Home's big action buttons, by its
/// label (Гүйлгээ, Мөнгө хүсэх, Дэлгэрэнгүй, Орлого, Найз урих), or null where
/// the character has none (the plain button is drawn). The art carries its
/// own label. All four under-10 cartoons have sets, in
/// `assets/images/kids/<set>/buttons/`; all four 10–13
/// characters have them, in `assets/images/teenegars/<art>/buttons/`.
String? accountActionArt(String label) {
  final avatar = appAvatar.value;
  final folder = switch (appAgeGroup.value) {
    AgeGroup.under10 when _kidsButtonSets.contains(avatar.stickerSet) =>
      'kids/${avatar.stickerSet}',
    AgeGroup.tween when _teenButtonSets.contains(avatar.art) =>
      'teenegars/${avatar.art}',
    _ => null,
  };
  if (folder == null) return null;
  final name = switch (label) {
    'Гүйлгээ' => 'transaction',
    'Мөнгө хүсэх' => 'charge',
    'Дэлгэрэнгүй' => 'detail',
    'Орлого' => 'revenue',
    'Найз урих' => 'invite-friend',
    _ => null,
  };
  return name == null ? null : 'assets/images/$folder/buttons/$name.webp';
}

/// Each button picture's width-to-height ratio, so a row of two can be
/// sized to match (`HomeActions`). Re-measure when a picture is replaced.
const actionArtAspect = <String, double>{
  'assets/images/kids/bear/buttons/charge.webp': 4.000,
  'assets/images/kids/bear/buttons/detail.webp': 4.000,
  'assets/images/kids/bear/buttons/invite-friend.webp': 4.000,
  'assets/images/kids/bear/buttons/revenue.webp': 4.000,
  'assets/images/kids/bear/buttons/transaction.webp': 4.000,
  'assets/images/kids/fox/buttons/charge.webp': 3.891,
  'assets/images/kids/fox/buttons/detail.webp': 3.937,
  'assets/images/kids/fox/buttons/invite-friend.webp': 3.745,
  'assets/images/kids/fox/buttons/revenue.webp': 3.846,
  'assets/images/kids/fox/buttons/transaction.webp': 3.937,
  'assets/images/kids/penguin/buttons/charge.webp': 3.817,
  'assets/images/kids/penguin/buttons/detail.webp': 3.846,
  'assets/images/kids/penguin/buttons/invite-friend.webp': 3.759,
  'assets/images/kids/penguin/buttons/revenue.webp': 3.846,
  'assets/images/kids/penguin/buttons/transaction.webp': 3.846,
  'assets/images/kids/rabbit/buttons/charge.webp': 4.049,
  'assets/images/kids/rabbit/buttons/detail.webp': 3.215,
  'assets/images/kids/rabbit/buttons/invite-friend.webp': 3.584,
  'assets/images/kids/rabbit/buttons/revenue.webp': 3.279,
  'assets/images/kids/rabbit/buttons/transaction.webp': 3.846,
  'assets/images/teenegars/bear/buttons/charge.webp': 3.834,
  'assets/images/teenegars/bear/buttons/detail.webp': 3.834,
  'assets/images/teenegars/bear/buttons/invite-friend.webp': 3.834,
  'assets/images/teenegars/bear/buttons/revenue.webp': 3.834,
  'assets/images/teenegars/bear/buttons/transaction.webp': 3.834,
  'assets/images/teenegars/cat/buttons/charge.webp': 3.704,
  'assets/images/teenegars/cat/buttons/detail.webp': 3.704,
  'assets/images/teenegars/cat/buttons/invite-friend.webp': 3.704,
  'assets/images/teenegars/cat/buttons/revenue.webp': 3.704,
  'assets/images/teenegars/cat/buttons/transaction.webp': 3.704,
  'assets/images/teenegars/fox/buttons/charge.webp': 3.810,
  'assets/images/teenegars/fox/buttons/detail.webp': 3.810,
  'assets/images/teenegars/fox/buttons/invite-friend.webp': 3.810,
  'assets/images/teenegars/fox/buttons/revenue.webp': 3.810,
  'assets/images/teenegars/fox/buttons/transaction.webp': 3.810,
  'assets/images/teenegars/rabbit/buttons/charge.webp': 3.499,
  'assets/images/teenegars/rabbit/buttons/detail.webp': 3.499,
  'assets/images/teenegars/rabbit/buttons/invite-friend.webp': 3.499,
  'assets/images/teenegars/rabbit/buttons/revenue.webp': 3.499,
  'assets/images/teenegars/rabbit/buttons/transaction.webp': 3.499,
};

/// The characters with action-button art: under 10 by sticker set, 10–13 by
/// art name.
const _kidsButtonSets = {'rabbit', 'bear', 'fox', 'penguin'};
const _teenButtonSets = {'fox', 'rabbit', 'bear', 'cat'};

/// The background art for an invoice card in Home's Нэхэмжлэх tab under 10,
/// with its width-to-height ratio (the card takes that shape so the art is
/// never stretched): a green frame for a paid invoice, a yellow one for any
/// still open, or null (the plain card) at other ages and on the dark
/// canvas, where the pale art would glare and hide the light text.
({String asset, double aspect})? invoiceCardArt(Invoice invoice) {
  if (appAgeGroup.value != AgeGroup.under10 || AppColors.isDark) return null;
  return invoice.status == InvoiceStatus.paid
      ? (asset: 'assets/images/kids/invoices/paid.webp', aspect: 1000 / 279)
      : (asset: 'assets/images/kids/invoices/pending.webp', aspect: 1000 / 408);
}

/// The background for one of the cards in Home's Карт tab under 10 on the
/// light canvas: [name] is `active` (green, the card in use), `pending`
/// (yellow, waiting on the parent) or `order` (purple, order a new one).
/// Drawn at its own proportions, scaled to the card's height and kept to
/// the right, so its decorated end sits by the badge and chevron. Null
/// (the plain card) at other ages and on the dark canvas.
DecorationImage? cardTabArt(String name) {
  if (appAgeGroup.value != AgeGroup.under10 || AppColors.isDark) return null;
  return DecorationImage(
    image: AssetImage('assets/images/kids/card_tab/$name.webp'),
    fit: BoxFit.cover,
    alignment: Alignment.centerRight,
    filterQuality: FilterQuality.high,
  );
}
