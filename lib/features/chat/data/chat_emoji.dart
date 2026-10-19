/// A category on the sheet's Эможи tab: the app's own 3D emoji, cut from
/// its emoji sheets into `assets/images/chat_emoji/<id>/<slug>.webp`
/// (160px). They're pictures, not Unicode, so a tap sends one as a message
/// of its own rather than typing it.
class ChatEmojiPack {
  const ChatEmojiPack(this.id, this.label, this.icon, this.emoji);

  final String id;

  /// The category's name, read out for its button.
  final String label;

  /// The emoji (a slug of [emoji]) the category's button shows.
  final String icon;

  /// Each emoji's file name and what a screen reader says for it.
  final List<(String, String)> emoji;

  String path(String slug) => 'assets/images/chat_emoji/$id/$slug.webp';
  List<String> get paths => [for (final (slug, _) in emoji) path(slug)];
}

/// What a screen reader says for an emoji, by its asset path.
String chatEmojiLabel(String path) {
  for (final pack in chatEmojiPacks) {
    for (final (slug, label) in pack.emoji) {
      if (pack.path(slug) == path) return label;
    }
  }
  return 'Эможи';
}

const chatEmojiPacks = [
  ChatEmojiPack('celebrate', 'Баяр', 'party_face', [
    ('smile', 'Инээмсэглэл'),
    ('grin', 'Ихээр инээх'),
    ('wink', 'Нүд ирмэх'),
    ('joy', 'Инээдээс нулимс'),
    ('relieved', 'Тайван'),
    ('party_face', 'Баярын нүүр'),
    ('popper', 'Конфетти'),
    ('raised_hands', 'Гар өргөх'),
    ('clap', 'Алга ташилт'),
    ('peace', 'Энх тайван'),
    ('ok', 'За'),
    ('thumbs_up', 'Гоё'),
    ('star_eyes', 'Гайхалтай'),
    ('sparkles', 'Гялалзах'),
    ('shooting_star', 'Харвасан од'),
    ('trophy', 'Цом'),
    ('medal', 'Медаль'),
    ('crown', 'Титэм'),
    ('fireworks', 'Салют'),
    ('sun', 'Нар'),
    ('hearts', 'Зүрхнүүд'),
  ]),
  ChatEmojiPack('love', 'Хайр', 'heart_eyes', [
    ('hug_heart', 'Зүрх тэврэх'),
    ('kiss_heart', 'Үнсэлт'),
    ('heart_eyes', 'Дурласан'),
    ('pink_heart', 'Ягаан зүрх'),
    ('blue_heart', 'Цэнхэр зүрх'),
    ('sparkle_heart', 'Гялалзсан зүрх'),
    ('gift_heart', 'Бэлэг зүрх'),
    ('two_hearts', 'Хоёр зүрх'),
    ('winged_heart', 'Далавчтай зүрх'),
    ('love_letter', 'Хайрын захидал'),
    ('bouquet', 'Баглаа цэцэг'),
    ('tulip', 'Алтанзул'),
    ('daisy', 'Цагаан цэцэг'),
    ('rose', 'Сарнай'),
    ('hibiscus', 'Ягаан цэцэг'),
    ('blossom', 'Интоорын цэцэг'),
    ('smiling_hearts', 'Зүрхтэй инээмсэглэл'),
    ('blush_hearts', 'Ичимхий'),
    ('pleading', 'Гуйх'),
    ('heart_face', 'Зүрх барих'),
    ('blow_kiss', 'Үнсэлт илгээх'),
    ('happy_hearts', 'Аз жаргалтай'),
    ('cheeks', 'Хацраа барих'),
    ('content', 'Сэтгэл хангалуун'),
    ('gift', 'Бэлэг'),
    ('handshake', 'Гар барих'),
    ('crossed_fingers', 'Хуруу завилах'),
    ('heart_hands', 'Зүрхэн гар'),
    ('bow', 'Тууз'),
    ('heart_bubble', 'Зүрхтэй мессеж'),
    ('teddy_hug', 'Баавгайн тэврэлт'),
    ('heart_hug', 'Зүрхний тэврэлт'),
  ]),
  ChatEmojiPack('feelings', 'Мэдрэмж', 'sob', [
    ('sob', 'Мэгшин уйлах'),
    ('sad_tear', 'Нулимс'),
    ('puppy_eyes', 'Өрөвдөлтэй'),
    ('grimace', 'Эвгүй'),
    ('dizzy', 'Толгой эргэх'),
    ('facepalm', 'Нүүрээ дарах'),
    ('sleepy', 'Нойрмог'),
    ('sick', 'Өвчтэй'),
    ('vomit', 'Бөөлжих'),
    ('melting', 'Хайлах'),
    ('eye_roll', 'Нүдээ эргэлдүүлэх'),
    ('scream', 'Айх'),
    ('angry', 'Уурласан'),
    ('huff', 'Хилэгнэх'),
    ('pensive', 'Гунигтай'),
    ('tired_tear', 'Ядарсан'),
    ('sweat', 'Хөлрөх'),
    ('cold', 'Даарах'),
    ('mind_blown', 'Гайхшрах'),
    ('confused', 'Ойлгохгүй'),
    ('thinking', 'Бодох'),
    ('disappointed', 'Сэтгэл гонсойх'),
    ('weary', 'Залхсан'),
    ('worried', 'Санаа зовох'),
    ('broken_heart', 'Шархалсан зүрх'),
    ('storm', 'Аянга'),
    ('wilted_rose', 'Гандсан сарнай'),
    ('warning', 'Анхааруулга'),
    ('cross', 'Үгүй'),
    ('low_battery', 'Цэнэг дууссан'),
    ('skull', 'Гавлын яс'),
    ('anger', 'Уур'),
  ]),
  ChatEmojiPack('symbols', 'Тэмдэг', 'check', [
    ('check', 'Тийм'),
    ('chat', 'Мессеж'),
    ('typing', 'Бичиж байна'),
    ('bell', 'Хонх'),
    ('megaphone', 'Чанга яригч'),
    ('idea', 'Санаа'),
    ('rocket', 'Пуужин'),
    ('hourglass', 'Элсэн цаг'),
    ('key', 'Түлхүүр'),
    ('lock', 'Цоож'),
    ('pin', 'Байршил'),
    ('money_bag', 'Мөнгөний уут'),
    ('coin', 'Зоос'),
    ('chart_up', 'Өсөлт'),
    ('chart_down', 'Бууралт'),
    ('siren', 'Дохио'),
    ('search', 'Хайх'),
    ('link', 'Холбоос'),
    ('bookmark', 'Хадгалах'),
    ('calendar', 'Хуанли'),
    ('folder', 'Хавтас'),
    ('star', 'Од'),
    ('heart', 'Зүрх'),
    ('plus', 'Нэмэх'),
    ('minus', 'Хасах'),
    ('info', 'Мэдээлэл'),
    ('caution', 'Болгоомжил'),
    ('question', 'Асуулт'),
    ('exclaim', 'Анхаар'),
  ]),
];

/// The reactions a long press on a message offers, in order, like a
/// messenger's: love, laugh, wow, sad, angry, like. The first is what a
/// double-tap gives.
const chatReactions = [
  'assets/images/chat_emoji/symbols/heart.webp',
  'assets/images/chat_emoji/celebrate/joy.webp',
  'assets/images/chat_emoji/feelings/scream.webp',
  'assets/images/chat_emoji/feelings/sob.webp',
  'assets/images/chat_emoji/feelings/angry.webp',
  'assets/images/chat_emoji/celebrate/thumbs_up.webp',
];

final _emojiOnly = RegExp(
  // The lint doesn't know `\p{…}` property escapes, which `unicode: true`
  // enables (the VM supports them).
  // ignore: valid_regexps
  r'^(?:\p{Extended_Pictographic}|\p{Emoji_Modifier}|\p{Regional_Indicator}'
  r'|\u200d|\ufe0f|\u20e3|\s)+$',
  unicode: true,
);

/// Whether [text] is nothing but emoji (and spaces), the way a message of
/// one to three of them is drawn large, with no bubble.
bool isEmojiOnly(String text) =>
    text.trim().isNotEmpty && _emojiOnly.hasMatch(text);
