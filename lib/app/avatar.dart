import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../widgets/ui.dart';

/// The companion the kid picks in "Аватар сонгох". Its set of images stands
/// in for the kid throughout Home and Profile.
enum AppAvatar {
  fox(
    id: 'fox',
    stickerSet: 'fox',
    name: 'Үнэгхэн',
    role: 'Гүйлгээний мастер',
    description: 'Мөнгөө хурдан, ухаалгаар тооцоолно!',
    tone: BadgeTone.sky,
    pick: FoxStickers.transfer,
    portrait: FoxStickers.avatar,
    savings: FoxStickers.piggy,
    stocks: FoxStickers.growth,
    rewards: FoxStickers.gift,
  ),
  bear(
    id: 'bear',
    stickerSet: 'bear',
    name: 'Бамбарууш',
    role: 'Хадгаламж сахигч',
    description: 'Мөнгөө зорилгодоо хүртэл найдвартай хадгална!',
    tone: BadgeTone.emerald,
    pick: BearStickers.jar,
    portrait: BearStickers.avatar,
    savings: BearStickers.piggy,
    stocks: BearStickers.growth,
    rewards: BearStickers.gift,
  ),
  bunny(
    id: 'bunny',
    stickerSet: 'rabbit',
    name: 'Бүжинхэн',
    role: 'Данс цэнэглэгч',
    description: 'Эрч хүчтэйгээр өдөр бүр даалгавар биелүүлнэ!',
    tone: BadgeTone.amber,
    pick: RabbitStickers.receive,
    portrait: RabbitStickers.avatar,
    savings: RabbitStickers.piggy,
    stocks: RabbitStickers.growth,
    rewards: RabbitStickers.gift,
  ),
  penguin(
    id: 'penguin',
    stickerSet: 'penguin',
    name: 'Шувуухай',
    role: 'Хяналтын нярав',
    description: 'Зарцуулалт ба тайлангаа нямбай тэмдэглэнэ!',
    tone: BadgeTone.slate,
    pick: PenguinStickers.report,
    portrait: PenguinStickers.avatar,
    savings: PenguinStickers.piggy,
    stocks: PenguinStickers.growth,
    rewards: PenguinStickers.gift,
  );

  const AppAvatar({
    required this.id,
    required this.stickerSet,
    required this.name,
    required this.role,
    required this.description,
    required this.tone,
    required this.pick,
    required this.portrait,
    required this.savings,
    required this.stocks,
    required this.rewards,
  });

  /// Stable key for storage. The display [name] shadows the enum's own
  /// `name`, so the saved value has to come from here.
  final String id;

  /// Folder of the sticker sheet the screens draw from (see [Stickers]).
  final String stickerSet;

  final String name;
  final String role;
  final String description;
  final BadgeTone tone;

  /// Shown on its picker card, and on Home for the main account.
  final String pick;

  /// Waving head-and-shoulders, for the round profile pictures.
  final String portrait;

  /// Home account images: savings (piggy bank), "Миний өв" (growing
  /// investment) and rewards (trophy).
  final String savings;
  final String stocks;
  final String rewards;
}

/// Screen illustrations in the chosen companion's sticker set. Getters, like the
/// `AppColors` accent, so they can't appear in `const` expressions;
/// `ArdKidsApp` rebuilds the tree when [appAvatar] changes.
abstract final class Stickers {
  static String _path(String name) {
    final set = appAvatar.value.stickerSet;
    return 'assets/images/$set/${set}_$name.png';
  }

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

  /// The bear and rabbit sheets drew an invite where the others have games,
  /// so those two show their sports sticker instead.
  static String get games =>
      _path(_noGames.contains(appAvatar.value.stickerSet) ? 'sports' : 'games');
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
