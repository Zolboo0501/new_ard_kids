import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../widgets/ui.dart';
import 'age_group.dart';

/// The avatar the teen picks in "Аватараа сонго", shown on Home and Profile.
///
/// The art follows [appAgeGroup]: under 10 gets the cartoon companions
/// (fox, bear, bunny, penguin), 10–13 and 14+ get the streetwear characters
/// (fox, bear, bunny, cat) from `assets/images/avatars/teen` and `/mature`.
/// The penguin only exists in the kids' set and the cat only in the older
/// ones; [forAge] swaps one for the other when the age range changes.
enum AppAvatar {
  fox(
    id: 'fox',
    stickerSet: 'fox',
    art: 'fox',
    kidsName: 'Үнэгхэн',
    olderName: 'Үнэг',
    role: 'Гүйлгээний мастер',
    description: 'Мөнгөө хурдан, ухаалгаар тооцоолно!',
    tone: BadgeTone.sky,
    pick: FoxStickers.transfer,
    kidsPortrait: FoxStickers.avatar,
    savings: FoxStickers.piggy,
    stocks: FoxStickers.growth,
    rewards: FoxStickers.gift,
  ),
  bear(
    id: 'bear',
    stickerSet: 'bear',
    art: 'bear',
    kidsName: 'Бамбарууш',
    olderName: 'Баавгай',
    role: 'Хадгаламж сахигч',
    description: 'Мөнгөө зорилгодоо хүртэл найдвартай хадгална!',
    tone: BadgeTone.emerald,
    pick: BearStickers.jar,
    kidsPortrait: BearStickers.avatar,
    savings: BearStickers.piggy,
    stocks: BearStickers.growth,
    rewards: BearStickers.gift,
  ),
  bunny(
    id: 'bunny',
    stickerSet: 'rabbit',
    art: 'rabbit',
    kidsName: 'Бүжинхэн',
    olderName: 'Туулай',
    role: 'Данс цэнэглэгч',
    description: 'Эрч хүчтэйгээр өдөр бүр даалгавар биелүүлнэ!',
    tone: BadgeTone.amber,
    pick: RabbitStickers.receive,
    kidsPortrait: RabbitStickers.avatar,
    savings: RabbitStickers.piggy,
    stocks: RabbitStickers.growth,
    rewards: RabbitStickers.gift,
  ),
  penguin(
    id: 'penguin',
    stickerSet: 'penguin',
    art: null,
    kidsName: 'Шувуухай',
    olderName: 'Шувуухай',
    role: 'Хяналтын нярав',
    description: 'Зарцуулалт ба тайлангаа нямбай тэмдэглэнэ!',
    tone: BadgeTone.slate,
    pick: PenguinStickers.report,
    kidsPortrait: PenguinStickers.avatar,
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
    kidsName: 'Муур',
    olderName: 'Муур',
    role: '',
    description: '',
    tone: BadgeTone.slate,
    pick: PenguinStickers.report,
    kidsPortrait: PenguinStickers.avatar,
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
    required this.kidsPortrait,
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

  /// The cartoon set's waving head-and-shoulders.
  final String kidsPortrait;

  /// Head and shoulders for the round profile pictures, in the set for
  /// [appAgeGroup].
  String get portrait => switch ((appAgeGroup.value, art)) {
    (AgeGroup.tween, final art?) =>
      'assets/images/avatars/teen/${art}_avatar.png',
    (AgeGroup.teen, final art?) =>
      'assets/images/avatars/mature/${art}_avatar.png',
    _ => kidsPortrait,
  };

  /// The avatars offered for [age]: the penguin for under 10, the cat above.
  static List<AppAvatar> forAge(AgeGroup age) => age == AgeGroup.under10
      ? const [fox, bear, bunny, penguin]
      : const [fox, bear, bunny, cat];

  /// This avatar, or its counterpart when [age] doesn't have it.
  AppAvatar inAge(AgeGroup age) =>
      forAge(age).contains(this) ? this : (this == penguin ? cat : penguin);

  /// Home account images: savings (piggy bank), "Миний өв" (growing
  /// investment) and rewards (trophy).
  final String savings;
  final String stocks;
  final String rewards;
}

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
