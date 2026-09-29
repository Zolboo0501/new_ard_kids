import 'package:flutter/painting.dart';

import '../../../app/accounts.dart';
import '../../../app/age_group.dart';
import '../../../app/avatar.dart';

/// The chosen character's card art for an account on Home, with the deep
/// shade of the card's own hue its text is set in, or null where the
/// character has none (the panel then draws its plain glyph card). So far
/// all four 10–13 characters (fox, rabbit, bear, cat) have sets, in `assets/images/teenegars/<art>/cards/`;
/// the inks are per account and shared by every set.
({String asset, Color ink})? accountCardArt(String account) {
  final art = appAvatar.value.art;
  if (appAgeGroup.value != AgeGroup.tween || !_sets.contains(art)) {
    return null;
  }
  // Each ink is at least 5.9:1 on its card's pale side.
  final (name, ink) = switch (account) {
    Accounts.main => ('main', const Color(0xFF0B3D91)),
    Accounts.savings => ('savings', const Color(0xFF9D1742)),
    Accounts.stocks => ('stocks', const Color(0xFF0B6B3A)),
    Accounts.rewards => ('rewards', const Color(0xFF4B2AA8)),
    _ => ('coin', const Color(0xFF8A4B00)),
  };
  return (asset: 'assets/images/teenegars/$art/cards/$name.webp', ink: ink);
}

/// The characters with a card set.
const _sets = {'fox', 'rabbit', 'bear', 'cat'};
