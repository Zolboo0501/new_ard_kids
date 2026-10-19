import 'package:flutter/foundation.dart';

import '../../../app/avatar.dart';
import 'chat_emoji.dart';

/// One message in a [ChatThread]. [mine] is true for what the teen sent.
class ChatMessage {
  ChatMessage({
    required this.text,
    required this.at,
    this.mine = false,
    this.reaction,
  }) : heart = false,
       sticker = null,
       emoji = false;

  /// A heart sent with the composer's heart button: drawn big, no bubble.
  ChatMessage.heart({required this.at, this.mine = false, this.reaction})
    : text = '❤',
      heart = true,
      sticker = null,
      emoji = false;

  /// A bean sticker ([sticker] is its asset path): drawn big, no bubble.
  ChatMessage.sticker(
    String this.sticker, {
    required this.at,
    this.mine = false,
    this.reaction,
  }) : text = 'Стикер',
       heart = false,
       emoji = false;

  /// A GIF ([sticker] is its asset path), drawn like a sticker; it plays on
  /// its own. The sheet's GIF tab has none yet.
  ChatMessage.gif(
    String this.sticker, {
    required this.at,
    this.mine = false,
    this.reaction,
  }) : text = 'GIF',
       heart = false,
       emoji = false;

  /// One of the app's 3D emoji ([sticker] is its asset path): drawn on its
  /// own like a sticker, smaller.
  ChatMessage.emoji(
    String this.sticker, {
    required this.at,
    this.mine = false,
    this.reaction,
  }) : text = 'Эможи',
       heart = false,
       emoji = true;

  /// The bubble's text, or what a sticker or heart reads as in the inbox.
  final String text;
  final DateTime at;
  final bool mine;
  final bool heart;

  /// The asset of a sticker, GIF or emoji message; null for text and hearts.
  final String? sticker;

  /// Whether [sticker] is one of the 3D emoji.
  final bool emoji;

  /// The reaction on the message (one of [chatReactions], drawn small on
  /// the bubble's corner): long-press to pick one, double-tap for a heart.
  String? reaction;
}

/// Another Ard KIDS user the teen can write to, found on "Шинэ мессеж" by
/// [username]. Chat stays inside the app: only kids with an Ard KIDS
/// account appear, each pictured by the avatar they picked.
class ChatUser {
  const ChatUser({
    required this.username,
    required this.name,
    required this.relation,
    required this.avatar,
    this.away,
  });

  /// Without the "@"; unique, so it also identifies their thread.
  final String username;
  final String name;

  /// Who they are to the teen ("Найз", "Ангийнхан", "Ах дүү").
  final String relation;

  /// The companion they picked; its portrait is their profile picture.
  final AppAvatar avatar;

  /// How long ago they were last in the app; null while they're active.
  final Duration? away;

  String get handle => '@$username';
  String get firstName => name.split(' ').first;
  bool get active => away == null;

  /// Under the name in a conversation's header.
  String get status => switch (away) {
    null => 'Идэвхтэй',
    final d => 'Идэвхтэй байсан: ${chatAgo(d)}',
  };
}

/// The Ard KIDS users the search knows about until the user API exists.
// TODO: search Ard KIDS users through the API.
const mockChatUsers = [
  ChatUser(
    username: 'saraa',
    name: 'Сараа Бат',
    relation: 'Ах дүү',
    avatar: AppAvatar.bunny,
  ),
  ChatUser(
    username: 'batbayar',
    name: 'Батбаяр Түвшин',
    relation: 'Ангийнхан',
    avatar: AppAvatar.bear,
    away: Duration(hours: 2),
  ),
  ChatUser(
    username: 'anujin',
    name: 'Анужин Ганбат',
    relation: 'Найз',
    avatar: AppAvatar.cat,
  ),
  ChatUser(
    username: 'bilguun',
    name: 'Билгүүн Дорж',
    relation: 'Найз',
    avatar: AppAvatar.fox,
    away: Duration(minutes: 25),
  ),
  ChatUser(
    username: 'khulan',
    name: 'Хулан Энхбаяр',
    relation: 'Ангийнхан',
    avatar: AppAvatar.bunny,
  ),
  ChatUser(
    username: 'nomin',
    name: 'Номин Сүх',
    relation: 'Ангийнхан',
    avatar: AppAvatar.cat,
    away: Duration(days: 1),
  ),
  ChatUser(
    username: 'erdene',
    name: 'Эрдэнэ Бат',
    relation: 'Найз',
    avatar: AppAvatar.bear,
  ),
  ChatUser(
    username: 'temuge',
    name: 'Тэмүүгэ Ганзориг',
    relation: 'Найз',
    avatar: AppAvatar.fox,
    away: Duration(hours: 5),
  ),
];

/// The users whose username contains [query] (a leading "@" and case are
/// ignored); none for an empty query.
List<ChatUser> searchChatUsers(String query) {
  final q = query.trim().toLowerCase().replaceFirst(RegExp('^@'), '');
  if (q.isEmpty) return const [];
  return [
    for (final u in mockChatUsers)
      if (u.username.contains(q)) u,
  ];
}

/// A conversation on the Чат tab, with another Ard KIDS user.
class ChatThread {
  ChatThread({
    required this.user,
    required this.messages,
    this.unread = 0,
    this.seen = false,
  });

  final ChatUser user;
  String get id => user.username;
  String get name => user.name;
  String get relation => user.relation;
  final List<ChatMessage> messages;

  /// Messages the teen hasn't opened yet; cleared when the thread opens.
  int unread;

  /// Whether the other person has seen the teen's last message: "Харсан"
  /// under it, "Илгээсэн" until then.
  bool seen;

  ChatMessage? get last => messages.isEmpty ? null : messages.last;
}

DateTime _ago(Duration d) => DateTime.now().subtract(d);

/// The conversations shown until the chat API exists.
// TODO: load threads and messages from the API.
final mockChatThreads = <ChatThread>[
  ChatThread(
    user: mockChatUsers[0],
    unread: 2,
    messages: [
      ChatMessage(
        text: 'Өнөөдөр сургуулиасаа хамт харих уу?',
        at: _ago(const Duration(hours: 3, minutes: 10)),
      ),
      ChatMessage(
        text: 'За тэгье 👍',
        at: _ago(const Duration(hours: 3, minutes: 5)),
        mine: true,
        reaction: chatReactions.first,
      ),
      ChatMessage(
        text: 'Хадгаламжийн зорилгоо биелүүлчихлээ! 🎉',
        at: _ago(const Duration(minutes: 12)),
      ),
      ChatMessage(
        text: 'Одоо PS5-даа ойртлоо.',
        at: _ago(const Duration(minutes: 11)),
      ),
      ChatMessage(text: '🎮🔥', at: _ago(const Duration(minutes: 10))),
    ],
  ),
  ChatThread(
    user: mockChatUsers[2],
    unread: 1,
    messages: [
      ChatMessage.sticker(
        'assets/images/avatars/bean/purple/chat/hello.webp',
        at: _ago(const Duration(minutes: 41)),
      ),
      ChatMessage.emoji(
        'assets/images/chat_emoji/celebrate/star_eyes.webp',
        at: _ago(const Duration(minutes: 40, seconds: 30)),
      ),
      ChatMessage(
        text: 'Маргааш кино үзэх үү? 🍿',
        at: _ago(const Duration(minutes: 40)),
      ),
    ],
  ),
  ChatThread(
    user: mockChatUsers[1],
    seen: true,
    messages: [
      ChatMessage(
        text: 'Маргаашийн даалгавар юу билээ?',
        at: _ago(const Duration(days: 1, hours: 2)),
        mine: true,
      ),
      ChatMessage(
        text: 'Математикийн 45-р хуудас.',
        at: _ago(const Duration(days: 1, hours: 1, minutes: 50)),
      ),
      ChatMessage.heart(
        at: _ago(const Duration(days: 1, hours: 1, minutes: 48)),
        mine: true,
      ),
    ],
  ),
  ChatThread(
    user: mockChatUsers[3],
    seen: true,
    messages: [
      ChatMessage(
        text: 'Тоглоомын мөнгийг хуваая.',
        at: _ago(const Duration(days: 3, hours: 4)),
        mine: true,
      ),
      ChatMessage(
        text: 'За, би өөрийнхөө хэсгийг явуулчихлаа.',
        at: _ago(const Duration(days: 3, hours: 3, minutes: 58)),
      ),
      ChatMessage.sticker(
        'assets/images/avatars/bean/orange/chat/thumbsup.webp',
        at: _ago(const Duration(days: 3, hours: 3, minutes: 58)),
      ),
      ChatMessage(
        text: 'Баярлалаа!',
        at: _ago(const Duration(days: 3, hours: 3, minutes: 57)),
        mine: true,
      ),
    ],
  ),
];

/// Bumped when a thread is started or gets a new message, so the Чат list
/// rebuilds even when it isn't the screen being returned to.
final chatThreadsChanged = ValueNotifier(0);

/// The thread with [user], started (at the top of the list, empty) if
/// there isn't one yet.
ChatThread chatThreadWith(ChatUser user) {
  final thread = chatThreadById(user.username);
  if (thread != null) return thread;
  final started = ChatThread(user: user, messages: []);
  mockChatThreads.insert(0, started);
  chatThreadsChanged.value++;
  return started;
}

/// The thread with [id], or null.
ChatThread? chatThreadById(String? id) {
  for (final t in mockChatThreads) {
    if (t.id == id) return t;
  }
  return null;
}

/// How long ago, short, the way the inbox shows it: "5 мин", "2 ц",
/// "3 өдөр", "1 долоо хоног".
String chatAgo(Duration d) {
  if (d.inMinutes < 1) return 'Дөнгөж сая';
  if (d.inHours < 1) return '${d.inMinutes} мин';
  if (d.inDays < 1) return '${d.inHours} ц';
  if (d.inDays < 7) return '${d.inDays} өдөр';
  return '${d.inDays ~/ 7} долоо хоног';
}

const _weekdays = [
  'Даваа',
  'Мягмар',
  'Лхагва',
  'Пүрэв',
  'Баасан',
  'Бямба',
  'Ням',
];

/// The centred stamp over a conversation's messages after a pause:
/// "Өнөөдөр 10:02", "Өчигдөр 16:45", "Пүрэв 09:30", "10 сарын 3, 09:30".
String chatStamp(DateTime at, {DateTime? now}) {
  now ??= DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  final time = '${two(at.hour)}:${two(at.minute)}';
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(at.year, at.month, at.day)).inDays;
  return switch (days) {
    0 => 'Өнөөдөр $time',
    1 => 'Өчигдөр $time',
    < 7 => '${_weekdays[at.weekday - 1]} $time',
    _ => '${at.month} сарын ${at.day}, $time',
  };
}
