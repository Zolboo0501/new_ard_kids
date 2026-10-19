import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/chat/data/chat_thread.dart';
import 'package:new_ard_kids/features/chat/presentation/widgets/chat_composer.dart';
import 'package:new_ard_kids/features/home/presentation/widgets/floating_nav_bar.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/ui.dart';

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

/// The heart icons drawn at [size]: 12 for a like, 44 for a sent heart.
Finder _heart(double size) => find.byWidgetPredicate(
  (w) => w is LineIcon && w.glyph == LineGlyph.heart && w.size == size,
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
    expect(find.text('Маргааш кино үзэх үү?'), findsOneWidget);

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

      final liked = _heart(12);
      final before = liked.evaluate().length;
      await tester.tap(find.text('Одоо PS5-даа ойртлоо.'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Одоо PS5-даа ойртлоо.'));
      await tester.pumpAndSettle();
      expect(liked, findsNWidgets(before + 1));

      final hearts = _heart(44);
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
}
