import '../../../app/avatar.dart';

/// One bean character's chat stickers: nine poses cut from its sticker
/// sheet, in `assets/images/avatars/bean/<bean>/chat/<pose>.webp`.
class ChatStickerSet {
  const ChatStickerSet({required this.avatar, required this.poses});

  /// The character the set draws (the cat stands for the purple bean, which
  /// the penguin shares).
  final AppAvatar avatar;
  final List<String> poses;

  String get bean => avatar.bean;
  String path(String pose) =>
      'assets/images/avatars/bean/$bean/chat/$pose.webp';
  List<String> get paths => [for (final p in poses) path(p)];
}

const _poses = [
  'hello',
  'excited',
  'wow',
  'sad',
  'angry',
  'cool',
  'love',
  'thumbsup',
  'party',
];

/// Every set; the pink bean has no "cool" pose but a sleepy one.
const chatStickerSets = [
  ChatStickerSet(avatar: AppAvatar.fox, poses: _poses),
  ChatStickerSet(avatar: AppAvatar.bear, poses: _poses),
  ChatStickerSet(
    avatar: AppAvatar.bunny,
    poses: [
      'hello',
      'excited',
      'wow',
      'sad',
      'angry',
      'love',
      'thumbsup',
      'party',
      'sleepy',
    ],
  ),
  ChatStickerSet(avatar: AppAvatar.cat, poses: _poses),
];

/// The sets with the teen's own character's first.
List<ChatStickerSet> chatStickerSetsFor(AppAvatar own) => [
  for (final s in chatStickerSets)
    if (s.bean == own.bean) s,
  for (final s in chatStickerSets)
    if (s.bean != own.bean) s,
];

/// What a screen reader says for a sticker, by its pose.
String chatStickerLabel(String path) =>
    switch (path.split('/').last.split('.').first) {
      'hello' => 'Сайн уу',
      'excited' => 'Хөөх',
      'wow' => 'Гайхсан',
      'sad' => 'Гунигтай',
      'angry' => 'Уурласан',
      'cool' => 'Дажгүй',
      'love' => 'Хайртай',
      'thumbsup' => 'Гоё',
      'party' => 'Баяр',
      'sleepy' => 'Нойрмог',
      _ => 'Стикер',
    };
