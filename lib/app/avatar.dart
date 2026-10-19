import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../widgets/ui.dart';
import 'age_group.dart';
import '../theme/app_theme.dart';

/// The avatar the teen picks in "Аватараа сонго", shown on Home and Profile.
///
/// Its picture ([portrait]) is a bean character for every age. The rest of
/// the art follows [appAgeGroup]: under 10 gets the cartoon companions' stickers
/// (fox, bear, bunny, penguin), 10–13 and 14+ the streetwear characters
/// (fox, bear, bunny, cat). The penguin only exists in the kids' set and the
/// cat only in the older ones; [forAge] swaps one for the other when the age
/// range changes.
enum AppAvatar {
  fox(
    id: 'fox',
    stickerSet: 'fox',
    art: 'fox',
    kidsName: 'Гангаа',
    olderName: 'Гангаа',
    role: 'QR төлбөрийн мастер',
    description: 'Утсаараа хурдан, аюулгүй төлнө!',
    tone: BadgeTone.sky,
    pick: FoxStickers.transfer,
    savings: FoxStickers.piggy,
    stocks: FoxStickers.growth,
    rewards: FoxStickers.gift,
  ),
  bear(
    id: 'bear',
    stickerSet: 'bear',
    art: 'bear',
    kidsName: 'Цахиа',
    olderName: 'Цахиа',
    role: 'Оноо цуглуулагч',
    description: 'Даалгавраа биелүүлж, оноо цуглуулна!',
    tone: BadgeTone.emerald,
    pick: BearStickers.jar,
    savings: BearStickers.piggy,
    stocks: BearStickers.growth,
    rewards: BearStickers.gift,
  ),
  bunny(
    id: 'bunny',
    stickerSet: 'rabbit',
    art: 'rabbit',
    kidsName: 'Хөөсөө',
    olderName: 'Хөөсөө',
    role: 'Зарлага хянагч',
    description: 'Мөнгөө юунд зарцуулснаа тэмдэглэнэ!',
    tone: BadgeTone.amber,
    pick: RabbitStickers.receive,
    savings: RabbitStickers.piggy,
    stocks: RabbitStickers.growth,
    rewards: RabbitStickers.gift,
  ),
  penguin(
    id: 'penguin',
    stickerSet: 'penguin',
    art: null,
    kidsName: 'Вайбаа',
    olderName: 'Вайбаа',
    role: 'Хадгаламжийн баатар',
    description: 'Мөнгөө зорилгодоо хүртэл хуримтлуулна!',
    tone: BadgeTone.slate,
    pick: PenguinStickers.report,
    savings: PenguinStickers.piggy,
    stocks: PenguinStickers.growth,
    rewards: PenguinStickers.gift,
  ),

  /// Only in the 10–13 and 14+ sets. It has no cartoon stickers, so the
  /// kid-set fields borrow the penguin's.
  cat(
    id: 'cat',
    stickerSet: 'penguin',
    art: 'cat',
    kidsName: 'Вайбаа',
    olderName: 'Вайбаа',
    role: 'Хадгаламжийн баатар',
    description: 'Мөнгөө зорилгодоо хүртэл хуримтлуулна!',
    tone: BadgeTone.slate,
    pick: PenguinStickers.report,
    savings: PenguinStickers.piggy,
    stocks: PenguinStickers.growth,
    rewards: PenguinStickers.gift,
  );

  const AppAvatar({
    required this.id,
    required this.stickerSet,
    required this.art,
    required this.kidsName,
    required this.olderName,
    required this.role,
    required this.description,
    required this.tone,
    required this.pick,
    required this.savings,
    required this.stocks,
    required this.rewards,
  });

  /// Stable key for storage. The display [name] shadows the enum's own
  /// `name`, so the saved value has to come from here.
  final String id;

  /// Folder of the sticker sheet the screens draw from (see [Stickers]).
  final String stickerSet;

  /// File name of the streetwear art, or null for the kids-only penguin.
  final String? art;

  final String kidsName;
  final String olderName;

  /// Diminutive for the cartoon set ("Үнэгхэн"), plain for the older ones.
  String get name =>
      appAgeGroup.value == AgeGroup.under10 ? kidsName : olderName;

  final String role;
  final String description;
  final BadgeTone tone;

  /// Shown on its picker card, and on Home for the main account.
  final String pick;

  /// The bean character as the teen's own picture, the same for every age:
  /// the avatar picker, the Home header, Profile and every other round
  /// profile picture. Head-and-shoulders cutouts of the full-body art in
  /// `assets/images/avatars/bean/` (only `picker/` is bundled).
  String get portrait => 'assets/images/avatars/bean/picker/$_bean.png';

  /// The colour of this character's bean, which names its art folders.
  String get _bean => switch (this) {
    fox => 'orange',
    bear => 'green',
    bunny => 'pink',
    cat || penguin => 'purple',
  };

  /// The whole bean character, a transparent cut-out (the art the welcome
  /// slides use), for places that show the companion standing rather than
  /// as a round head: the Home tour's guide.
  String get fullBody =>
      'assets/images/welcome/${switch (this) {
        fox => 'qr',
        bear => 'rewards',
        bunny => 'spending',
        cat || penguin => 'goal',
      }}_bean.webp';

  /// What the popup shows when the avatar has just been changed (see
  /// `showAvatarReveal`): Гангаа's own full-size picture (`orange.png` cut
  /// out of its background, the original isn't bundled), [fullBody] for the
  /// others.
  String get revealArt => switch (this) {
    fox => 'assets/images/avatars/bean/orange_cut.webp',
    _ => fullBody,
  };

  /// What the reward toast (`showRewardToast`) shows for [pose]: the
  /// character's own bean cheering, with coins or with its savings.
  String rewardArt(RewardPose pose) =>
      'assets/images/avatars/bean/$_bean/${pose.name}.webp';

  /// The character's mother or father as a round head crop, for the parent
  /// pictures on the parent-link and profile screens. Cut from the full-body
  /// art beside it in `assets/images/teenegars/<art>/parent/`.
  ///
  /// Only for the older sets: it is drawn in the same streetwear style as
  /// their portraits, so under 10 it would sit oddly beside the cartoon
  /// companions, which keep their own mom/dad stickers. Null there, and for
  /// the kids-only penguin, which has no streetwear art.
  String? parentFace({required bool dad}) =>
      !Stickers.companionArt ||
          art == null ||
          appAgeGroup.value == AgeGroup.under10
      ? null
      : 'assets/images/teenegars/$art/parent/${dad ? 'dad' : 'mom'}_head.png';

  /// The avatars offered for [age]: the penguin for under 10, the cat above.
  static List<AppAvatar> forAge(AgeGroup age) => age == AgeGroup.under10
      ? const [fox, bear, bunny, penguin]
      : const [fox, bear, bunny, cat];

  /// This avatar, or its counterpart when [age] doesn't have it.
  AppAvatar inAge(AgeGroup age) =>
      forAge(age).contains(this) ? this : (this == penguin ? cat : penguin);

  /// The accent that goes with this character: picking it in the avatar
  /// picker also sets the theme (the penguin shares the cat's, since one
  /// stands in for the other across the age ranges).
  AppThemeChoice get accent => switch (this) {
    fox => AppThemeChoice.sky,
    bear => AppThemeChoice.blue,
    bunny => AppThemeChoice.pink,
    cat || penguin => AppThemeChoice.indigo,
  };

  /// Home account images: savings (piggy bank), "Миний өв" (growing
  /// investment) and rewards (trophy).
  final String savings;
  final String stocks;
  final String rewards;
}

/// How the character greets a reward ([AppAvatar.rewardArt]): cheering for a
/// transfer done, with coins for an invite, with its savings (a piggy bank,
/// a coin stack) for a savings deposit or a new goal.
enum RewardPose { success, coins, savings }

/// Screen illustrations in the chosen companion's sticker set. Getters, like the
/// `AppColors` accent, so they can't appear in `const` expressions;
/// `ArdKidsApp` rebuilds the tree when [appAvatar] changes.
///
/// For 10–13 the set comes from `assets/images/teenegars/<set>/` where that
/// set has the sticker ([_teen]); anything it lacks falls back to the kids'
/// set in `assets/images/kids/<set>/`.
abstract final class Stickers {
  static String _path(String name) {
    if (_hasOwn(name)) {
      final teen = _teenSet!;
      return 'assets/images/teenegars/$teen/${teen}_$name.png';
    }
    final set = appAvatar.value.stickerSet;
    return 'assets/images/kids/$set/${set}_$name.png';
  }

  /// The 10–13 sheet for the chosen character (its streetwear art name, so
  /// the cat gets its own sheet rather than the penguin's), or null.
  static String? get _teenSet =>
      appAgeGroup.value == AgeGroup.tween ? appAvatar.value.art : null;

  /// Any sticker by [name]: the 10–13 sheet's when it has one, else
  /// [fallback]. For the extras only some sheets draw ("fish", "relax").
  static String named(String name, {required String fallback}) =>
      _hasOwn(name) ? _path(name) : fallback;

  /// Whether screens may stand the teen's avatar on their summary card
  /// (`AvatarCardArt`): under 10 and 10–13 do, 14+ keeps the plain card for
  /// its grown-up look.
  static bool get onCards => appAgeGroup.value != AgeGroup.teen;

  /// Whether the old companions' own art is drawn: these stickers as icons
  /// and people pictures, the Home card, row and button art, and the
  /// parents' faces. Off since the bean characters replaced them as the
  /// avatar; the bean set has none of that art yet, so the screens show the
  /// plain cards, line icons and initials, and the bean portrait where the
  /// avatar itself appears.
  static const companionArt = false;

  /// The stickers each 10–13 set has, cut from its sheet.
  static const _teen = {
    'fox': {
      'avatar',
      'calculator',
      'card',
      'cart',
      'coin',
      'coins',
      'edit',
      'friends',
      'gift',
      'goal',
      'growth',
      'home',
      'lesson',
      'lock',
      'love',
      'notification',
      'payment',
      'peace',
      'piggy',
      'profile',
      'qr',
      'report',
      'send',
      'shield',
      'shopping',
      'study',
      'success',
      'transfer',
    },
    'bear': {
      'avatar',
      'ball',
      'card',
      'coin',
      'coins',
      'drink',
      'friends',
      'games',
      'gift',
      'goal',
      'growth',
      'home',
      'jump',
      'lesson',
      'music',
      'payment',
      'piggy',
      'profile',
      'qr',
      'report',
      'shield',
      'shopping',
      'snack',
      'sports',
      'study',
      'success',
      'transfer',
      'travel',
    },
    'rabbit': {
      'avatar',
      'ball',
      'card',
      'coin',
      'coins',
      'cool',
      'drink',
      'games',
      'gift',
      'goal',
      'growth',
      'home',
      'idea',
      'jump',
      'lesson',
      'love',
      'music',
      'payment',
      'profile',
      'qr',
      'report',
      'shield',
      'shopping',
      'snack',
      'sports',
      'study',
      'success',
      'transfer',
      'travel',
    },
    'cat': {
      'art',
      'avatar',
      'ball',
      'books',
      'calm',
      'card',
      'chill',
      'coin',
      'contacts',
      'cool',
      'drink',
      'fish',
      'friends',
      'games',
      'gift',
      'goal',
      'growth',
      'idea',
      'lesson',
      'love',
      'music',
      'online',
      'qr',
      'relax',
      'report',
      'school',
      'snack',
      'sports',
      'study',
      'success',
      'transfer',
      'travel',
    },
  };

  static String get addFriend => _path('add_friend');
  static String get avatar => _path('avatar');
  static String get calculator => _path('calculator');
  static String get card => _path('card');
  static String get coin => _path('coin');
  static String get coins => _path('coins');
  static String get contacts => _path('contacts');
  static String get edit => _path('edit');
  static String get family => _path('family');
  static String get friends => _path('friends');
  static String get gift => _path('gift');
  static String get goal => _path('goal');
  static String get growth => _path('growth');
  static String get home => _path('home');
  static String get jar => _path('jar');
  static String get notification => _path('notification');
  static String get piggy => _path('piggy');
  static String get profile => _path('profile');
  static String get receive => _path('receive');
  static String get report => _path('report');
  static String get shield => _path('shield');
  static String get success => _path('success');
  static String get transfer => _path('transfer');

  // Hobbies, people and everyday things, from each set's second sheet.
  static String get art => _path('art');
  static String get books => _path('books');
  static String get dad => _path('dad');
  static String get lesson => _path('lesson');
  static String get lock => _path('lock');
  static String get love => _path('love');
  static String get mom => _path('mom');
  static String get payment => _path('payment');
  static String get qr => _path('qr');
  static String get siblings => _path('siblings');
  static String get snack => _path('snack');
  static String get sports => _path('sports');
  static String get study => _path('study');
  static String get travel => _path('travel');

  // Only on some 10–13 sheets; other sets fall back to their own closest
  // sticker.
  static String get cart => _hasOwn('cart') ? _path('cart') : payment;
  static String get peace => _hasOwn('peace') ? _path('peace') : friends;
  static String get send => _hasOwn('send') ? _path('send') : transfer;
  static String get shopping =>
      _hasOwn('shopping') ? _path('shopping') : payment;
  static String get music => _hasOwn('music') ? _path('music') : games;
  static String get jump => _hasOwn('jump') ? _path('jump') : sports;
  static String get ball => _hasOwn('ball') ? _path('ball') : sports;
  static String get drink => _hasOwn('drink') ? _path('drink') : snack;
  static String get cool => _hasOwn('cool') ? _path('cool') : avatar;
  static String get idea => _hasOwn('idea') ? _path('idea') : lesson;

  static bool _hasOwn(String name) => _teen[_teenSet]?.contains(name) ?? false;

  /// The kids' bear and rabbit sheets drew an invite where the others have
  /// games, so those two show their sports sticker instead, unless their
  /// 10–13 sheet has one.
  static String get games =>
      _hasOwn('games') || !_noGames.contains(appAvatar.value.stickerSet)
      ? _path('games')
      : _path('sports');
  static const _noGames = {'bear', 'rabbit'};
}

/// The chosen companion. Home and Profile listen to it, so a change made in
/// the picker shows as soon as it pops.
final appAvatar = ValueNotifier(AppAvatar.fox);

/// Keeps [appAvatar] in secure storage so it survives an app restart.
///
/// Like `ThemeStore`, storage errors never reach the UI: a failed read keeps
/// the default and a failed write keeps the choice for this session only.
abstract final class AvatarStore {
  static const _key = 'app_avatar';
  static const _storage = FlutterSecureStorage();

  /// Applies the saved avatar to [appAvatar]. Called before `runApp`.
  static Future<void> load() async {
    try {
      final saved = await _storage.read(key: _key);
      final avatar = AppAvatar.values.where((a) => a.id == saved).firstOrNull;
      if (avatar != null) appAvatar.value = avatar;
    } catch (e) {
      debugPrint('AvatarStore.load failed: $e');
    }
  }

  static Future<void> save(AppAvatar avatar) async {
    try {
      await _storage.write(key: _key, value: avatar.id);
    } catch (e) {
      debugPrint('AvatarStore.save failed: $e');
    }
  }
}
