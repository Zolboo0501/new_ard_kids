import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The age range picked on "Насаа сонгох" during registration. It picks the
/// avatar art: the cartoon companions for under 10, the streetwear set for
/// 10–13 and its older take for 14+ (see `AppAvatar`).
enum AgeGroup {
  under10('10-аас доош', 'Бага ангийн сурагч'),
  tween('10–13 нас', 'Дунд ангийн сурагч'),
  teen('14–18 нас', 'Ахлах ангийн сурагч');

  const AgeGroup(this.label, this.hint);

  final String label;
  final String hint;
}

/// The teen's age range. `ArdKidsApp` rebuilds the tree when it changes, so
/// avatars already on screen switch to the new set.
///
/// Registration does not ask for it any more, so every new account starts on
/// [AgeGroup.teen]; only a saved value moves it.
final appAgeGroup = ValueNotifier(AgeGroup.teen);

/// Keeps [appAgeGroup] in secure storage so it survives an app restart.
///
/// Like `AvatarStore`, storage errors never reach the UI: a failed read keeps
/// the default and a failed write keeps the choice for this session only.
abstract final class AgeGroupStore {
  static const _key = 'app_age_group';
  static const _storage = FlutterSecureStorage();

  /// Applies the saved age range to [appAgeGroup]. Called before `runApp`.
  static Future<void> load() async {
    try {
      final saved = await _storage.read(key: _key);
      final group = AgeGroup.values.asNameMap()[saved];
      if (group != null) appAgeGroup.value = group;
    } catch (e) {
      debugPrint('AgeGroupStore.load failed: $e');
    }
  }

  static Future<void> save(AgeGroup group) async {
    try {
      await _storage.write(key: _key, value: group.name);
    } catch (e) {
      debugPrint('AgeGroupStore.save failed: $e');
    }
  }
}
