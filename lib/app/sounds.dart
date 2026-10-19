import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Short UI sounds from `assets/sound/`. They mix with whatever else is
/// playing, without pausing the teen's music, and stay quiet when the phone
/// is on silent (the iOS ambient category). Tests swap [instance] for a
/// silent one in `test/flutter_test_config.dart`, since there is no audio
/// plugin there.
class AppSounds {
  const AppSounds();

  static AppSounds instance = const AppSounds();

  /// The avatar popping up on Home after it was changed (`showAvatarReveal`).
  static const pick = 'sound/pick.mp3';

  /// A reward given (`showRewardToast`: a transfer, a savings deposit, a new
  /// goal, an invite shared).
  static const purchase = 'sound/purchase.mp3';

  static AudioPlayer? _player;

  Future<void> play(String asset) async {
    try {
      final player = _player ??= await _create();
      await player.stop();
      await player.play(AssetSource(asset));
    } catch (e) {
      // A missing sound must never break the screen that asked for it.
      debugPrint('AppSounds.play($asset) failed: $e');
    }
  }

  static Future<AudioPlayer> _create() async {
    final player = AudioPlayer();
    await player.setReleaseMode(ReleaseMode.stop);
    await player.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
        android: const AudioContextAndroid(
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.none,
        ),
      ),
    );
    return player;
  }
}
