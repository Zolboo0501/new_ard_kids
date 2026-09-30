import 'package:flutter/painting.dart';

import '../../../app/accounts.dart';
import '../../../app/age_group.dart';
import '../../../app/avatar.dart';

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
/// `assets/images/kids/<set>/rows/{savings,stocks,rewards}.webp`.
({String asset, Color ink, Color tint})? accountRowArt(String account) {
  if (appAgeGroup.value != AgeGroup.under10 ||
      !_kidsRowSets.contains(appAvatar.value.stickerSet)) {
    return null;
  }
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
    asset: 'assets/images/kids/${appAvatar.value.stickerSet}/rows/$name.webp',
    ink: ink!,
    tint: tint!,
  );
}

/// The under-10 characters with a row banner set.
const _kidsRowSets = {'fox', 'bear', 'rabbit', 'penguin'};

/// The chosen character's art for one of Home's big action buttons, by its
/// label (Гүйлгээ, Мөнгө хүсэх, Дэлгэрэнгүй, Орлого, Найз урих), or null where the character has
/// none (the plain button is drawn). The art carries its own label. All
/// four under-10 cartoons have sets, in `assets/images/kids/<set>/buttons/`.
String? accountActionArt(String label) {
  final set = appAvatar.value.stickerSet;
  if (appAgeGroup.value != AgeGroup.under10 || !_kidsButtonSets.contains(set)) {
    return null;
  }
  final name = switch (label) {
    'Гүйлгээ' => 'transaction',
    'Мөнгө хүсэх' => 'charge',
    'Дэлгэрэнгүй' => 'detail',
    'Орлого' => 'revenue',
    'Найз урих' => 'invite-friend',
    _ => null,
  };
  return name == null ? null : 'assets/images/kids/$set/buttons/$name.webp';
}

/// The under-10 characters with action-button art.
const _kidsButtonSets = {'rabbit', 'bear', 'fox', 'penguin'};
