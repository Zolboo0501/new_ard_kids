import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'dart:io';

import 'package:new_ard_kids/features/chat/data/chat_emoji.dart';
import 'package:new_ard_kids/features/chat/data/chat_stickers.dart';
import 'package:new_ard_kids/features/chat/data/chat_thread.dart';
import 'package:new_ard_kids/features/chat/presentation/widgets/chat_composer.dart';
import 'package:new_ard_kids/features/chat/presentation/widgets/chat_reaction_bar.dart';
import 'package:new_ard_kids/features/home/presentation/widgets/floating_nav_bar.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/app_text.dart';

Future<GoRouter> _pumpApp(WidgetTester tester, String location) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final router = AppRoutes.createRouter(initialLocation: location);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
  );
  await tester.pumpAndSettle();
  return router;
}

/// The reaction badges on bubbles showing [path].
Finder _reaction(String path) => find.byWidgetPredicate(
  (w) =>
      w is Image &&
      w.image is AssetImage &&
      (w.image as AssetImage).assetName == path &&
      w.width == 18,
);

/// The hearts sent from the composer: the ❤️ emoji drawn 56pt.
Finder _sentHeart() => find.byWidgetPredicate(
  (w) =>
      w is Image &&
      w.image is AssetImage &&
      (w.image as AssetImage).assetName == chatReactions.first &&
      w.width == 56,
);

void main() {
  testWidgets('Chat: the bar opens the tab, a row opens its thread', (
    tester,
  ) async {
    final router = await _pumpApp(tester, AppRoutes.home);

    await tester.tap(
      find.descendant(
        of: find.byType(FloatingNavBar),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Чат',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), AppRoutes.chat);
    expect(find.text('Анужин Ганбат'), findsOneWidget);

    await tester.tap(find.text('Анужин Ганбат'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), AppRoutes.chatThreadOf('anujin'));
    expect(find.text('Маргааш кино үзэх үү? 🍿'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(ChatComposer),
        matching: find.byType(TextField),
      ),
      'Тэгье!',
    );
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Илгээх'));
    await tester.pumpAndSettle();
    expect(find.text('Тэгье!'), findsOneWidget);
    // Under the teen's newest message until it's read.
    expect(find.text('Илгээсэн'), findsOneWidget);
  });

  test('Chat: username search ignores "@" and case', () {
    expect(searchChatUsers(''), isEmpty);
    expect(searchChatUsers('@KHU').map((u) => u.username), ['khulan']);
    expect(searchChatUsers('zzz'), isEmpty);
  });

  testWidgets('New chat: find a username and start writing to them', (
    tester,
  ) async {
    final router = await _pumpApp(tester, AppRoutes.chat);

    await tester.tap(find.bySemanticsLabel('Шинэ чат'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), AppRoutes.newChat);

    final field = find.byType(TextField);
    await tester.enterText(field, 'zzz');
    await tester.pump();
    expect(
      find.text('«zzz» нэртэй Ard KIDS хэрэглэгч олдсонгүй.'),
      findsOneWidget,
    );

    await tester.enterText(field, '@nomi');
    await tester.pump();
    expect(find.text('Номин Сүх'), findsOneWidget);

    await tester.tap(find.text('Номин Сүх'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), AppRoutes.chatThreadOf('nomin'));
    expect(find.text('Анхны мессежээ бичээрэй.'), findsOneWidget);

    // Back goes to the list (the search was replaced), which now has her.
    router.pop();
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), AppRoutes.chat);
    expect(find.text('Номин Сүх'), findsOneWidget);
  });

  testWidgets(
    'Thread: double-tap likes a message, the heart button sends one',
    (tester) async {
      await _pumpApp(tester, AppRoutes.chatThreadOf('saraa'));
      expect(find.text('Одоо PS5-даа ойртлоо.'), findsOneWidget);

      final liked = _reaction(chatReactions.first);
      final before = liked.evaluate().length;
      await tester.tap(find.text('Одоо PS5-даа ойртлоо.'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Одоо PS5-даа ойртлоо.'));
      await tester.pumpAndSettle();
      expect(liked, findsNWidgets(before + 1));

      final hearts = _sentHeart();
      final sent = hearts.evaluate().length;
      await tester.tap(find.bySemanticsLabel('Зүрх илгээх'));
      await tester.pumpAndSettle();
      expect(hearts, findsNWidgets(sent + 1));
      expect(find.text('Илгээсэн'), findsOneWidget);
    },
  );

  test('Chat: stamps and ages read like an inbox', () {
    final now = DateTime(2026, 10, 19, 12);
    expect(chatStamp(DateTime(2026, 10, 19, 9, 5), now: now), 'Өнөөдөр 09:05');
    expect(
      chatStamp(DateTime(2026, 10, 18, 16, 45), now: now),
      'Өчигдөр 16:45',
    );
    expect(chatStamp(DateTime(2026, 10, 15, 8, 0), now: now), 'Пүрэв 08:00');
    expect(
      chatStamp(DateTime(2026, 10, 3, 9, 30), now: now),
      '10 сарын 3, 09:30',
    );
    expect(chatAgo(const Duration(minutes: 12)), '12 мин');
    expect(chatAgo(const Duration(hours: 3)), '3 ц');
    expect(chatAgo(const Duration(days: 9)), '1 долоо хоног');
  });

  test('Stickers: every pose of every set is bundled', () {
    for (final set in chatStickerSets) {
      expect(set.poses, hasLength(9));
      for (final path in set.paths) {
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    }
  });

  for (final (tab, path) in [
    ('Стикер', 'assets/images/avatars/bean/orange/chat/party.webp'),
  ]) {
    testWidgets('$tab: the tab shows your own character first and sends', (
      tester,
    ) async {
      await _pumpApp(tester, AppRoutes.chatThreadOf('erdene'));
      Finder sent() => find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName == path &&
            w.width == 120,
      );
      expect(sent(), findsNothing);

      await tester.tap(find.bySemanticsLabel('GIF, эможи, стикер'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      // The sheet opens on Эможи; on Стикер the fox (the default avatar) comes first, so its party pose is on
      // show without switching characters.
      await tester.tap(find.byKey(ValueKey(path)));
      await tester.pumpAndSettle();
      expect(sent(), findsOneWidget);
    });
  }

  test('Emoji: only emoji (and spaces) count as emoji-only', () {
    expect(isEmojiOnly('😀'), isTrue);
    expect(isEmojiOnly('🎮 🔥'), isTrue);
    expect(isEmojiOnly('❤️👍🏽'), isTrue);
    expect(isEmojiOnly('Сайн уу 😀'), isFalse);
    expect(isEmojiOnly('123'), isFalse);
    expect(isEmojiOnly('  '), isFalse);
  });

  testWidgets('Emoji: a few typed alone send large', (tester) async {
    await _pumpApp(tester, AppRoutes.chatThreadOf('khulan'));
    // Emoji come from the phone's keyboard, as plain text.
    await tester.enterText(
      find.descendant(
        of: find.byType(ChatComposer),
        matching: find.byType(TextField),
      ),
      '😀🔥',
    );
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Илгээх'));
    await tester.pumpAndSettle();
    final sent = tester.widget<AppText>(find.widgetWithText(AppText, '😀🔥'));
    expect(sent.size, 40);
  });

  testWidgets('GIF: the tab is there but empty', (tester) async {
    await _pumpApp(tester, AppRoutes.chatThreadOf('erdene'));
    await tester.tap(find.bySemanticsLabel('GIF, эможи, стикер'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GIF'));
    await tester.pumpAndSettle();
    expect(find.text('GIF алга байна'), findsOneWidget);
  });

  test('Emoji: every 3D emoji is bundled, with a label', () {
    expect(chatEmojiPacks.map((p) => p.label), [
      'Баяр',
      'Хайр',
      'Мэдрэмж',
      'Тэмдэг',
    ]);
    for (final pack in chatEmojiPacks) {
      for (final path in pack.paths) {
        expect(File(path).existsSync(), isTrue, reason: path);
        expect(chatEmojiLabel(path), isNot('Эможи'), reason: path);
      }
    }
  });

  testWidgets('Emoji: the tab opens on Баяр, a chip switches, a tap sends', (
    tester,
  ) async {
    await _pumpApp(tester, AppRoutes.chatThreadOf('erdene'));
    const heart = 'assets/images/chat_emoji/love/heart_eyes.webp';
    Finder sent(String path) => find.byWidgetPredicate(
      (w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName == path &&
          w.width == 64,
    );

    await tester.tap(find.bySemanticsLabel('GIF, эможи, стикер'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(
        const ValueKey('assets/images/chat_emoji/celebrate/smile.webp'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.bySemanticsLabel('Хайр'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey(heart)));
    await tester.pumpAndSettle();
    expect(sent(heart), findsOneWidget);
  });

  testWidgets('Reactions: a long press offers them; picking twice clears', (
    tester,
  ) async {
    await _pumpApp(tester, AppRoutes.chatThreadOf('bilguun'));
    const message = 'Тоглоомын мөнгийг хуваая.';
    final laugh = _reaction(chatReactions[1]);
    expect(laugh, findsNothing);

    await tester.longPress(find.text(message));
    await tester.pumpAndSettle();
    expect(find.byType(ChatReactionBar), findsOneWidget);
    await tester.tap(find.byKey(ValueKey(chatReactions[1])));
    await tester.pumpAndSettle();
    expect(find.byType(ChatReactionBar), findsNothing);
    expect(laugh, findsOneWidget);

    // The same one again takes it off.
    await tester.longPress(find.text(message));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey(chatReactions[1])));
    await tester.pumpAndSettle();
    expect(laugh, findsNothing);
  });
}
