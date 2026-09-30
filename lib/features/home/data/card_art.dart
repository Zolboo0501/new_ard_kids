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
