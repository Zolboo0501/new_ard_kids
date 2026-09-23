import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../widgets/ui.dart';

/// The companion the kid picks in "Аватар сонгох". Its set of images stands
/// in for the kid throughout Home and Profile.
enum AppAvatar {
  fox(
    id: 'fox',
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
    name: 'Бамбарууш',
    role: 'Хадгаламж сахигч',
    description: 'Мөнгөө зорилгодоо хүртэл найдвартай хадгална!',
    tone: BadgeTone.emerald,
    pick: Mascots.bearCard,
    portrait: Mascots.bearPortrait,
    savings: Mascots.bearPiggy,
    stocks: Mascots.bearGrow,
    rewards: Mascots.bearTrophy,
  ),
  bunny(
    id: 'bunny',
    name: 'Бүжинхэн',
    role: 'Данс цэнэглэгч',
    description: 'Эрч хүчтэйгээр өдөр бүр даалгавар биелүүлнэ!',
    tone: BadgeTone.amber,
    pick: Mascots.bunnyBattery,
    portrait: Mascots.bunnyPortrait,
    savings: Mascots.bunnyPiggy,
    stocks: Mascots.bunnyGrow,
    rewards: Mascots.bunnyTrophy,
  ),
  penguin(
    id: 'penguin',
    name: 'Шувуухай',
    role: 'Хяналтын нярав',
    description: 'Зарцуулалт ба тайлангаа нямбай тэмдэглэнэ!',
    tone: BadgeTone.slate,
    pick: Mascots.penguinChecklist,
    portrait: Mascots.penguinPortrait,
    savings: Mascots.penguinPiggy,
    stocks: Mascots.penguinGrow,
    rewards: Mascots.penguinTrophy,
  );

  const AppAvatar({
    required this.id,
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
