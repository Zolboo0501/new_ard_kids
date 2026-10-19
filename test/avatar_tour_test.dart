import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/app/tour_store.dart';
import 'package:new_ard_kids/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester, String route) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = AppRoutes.createRouter(initialLocation: route);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
  );
  await _settle(tester);
}

/// Long enough for a tour step's scroll and spotlight to finish. Timed
/// pumps, not pumpAndSettle: the QR scanner's line animates forever.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

/// Taps Дараах through every step, then the last button, checking each
/// button is fully on screen (a tall spotlight once pushed it off).
Future<void> _walk(WidgetTester tester) async {
  void expectOnScreen(String label) {
    final rect = tester.getRect(find.text(label));
    expect(
      const Rect.fromLTWH(0, 0, 390, 844).intersect(rect),
      rect,
      reason: '$label off screen',
    );
  }

  var guard = 0;
  while (find.text('Дараах').evaluate().isNotEmpty && guard++ < 10) {
    expectOnScreen('Дараах');
    await tester.tap(find.text('Дараах'));
    await _settle(tester);
  }
  expectOnScreen('Эхэлцгээе');
  await tester.tap(find.text('Эхэлцгээе'));
  await _settle(tester);
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    TourStore.reset(enabled: true);
  });
  tearDown(() => TourStore.reset());

  // Home and every screen it opens, with each one's tour id.
  for (final (route, id) in [
    (AppRoutes.home, 'home'),
    (AppRoutes.transferAmount, 'transfer_amount'),
    (AppRoutes.requestAmount, 'request_amount'),
    (AppRoutes.qrScan, 'qr_scan'),
    (AppRoutes.invoiceHistory, 'invoice_history'),
    (AppRoutes.savingsAccount, 'savings_account'),
    (AppRoutes.savingsDeposit, 'savings_deposit'),
    (AppRoutes.rewardsAccount, 'rewards_account'),
    (AppRoutes.stocks, 'stocks'),
    (AppRoutes.card, 'card'),
    (AppRoutes.cardOrder, 'card_order'),
    (AppRoutes.inviteFriends, 'invite_friends'),
    (AppRoutes.notifications, 'notifications'),
    (AppRoutes.security, 'security'),
  ]) {
    testWidgets('Avatar tour: $route walks through once', (tester) async {
      await _pump(tester, route);
      expect(find.textContaining('Би '), findsWidgets, reason: route);
      await _walk(tester);
      expect(find.text('Дараах'), findsNothing, reason: route);
      expect(tester.takeException(), isNull, reason: route);
      expect(TourStore.pending(id), isFalse, reason: route);
      expect(
        await const FlutterSecureStorage().read(key: TourStore.keyFor(id)),
        'true',
        reason: route,
      );
    });
  }

  testWidgets('Avatar tour: Алгасах ends it straight away', (tester) async {
    await _pump(tester, AppRoutes.home);
    await tester.tap(find.text('Алгасах'));
    await _settle(tester);
    expect(find.text('Дараах'), findsNothing);
    expect(TourStore.pending('home'), isFalse);
  });

  testWidgets('Avatar tour: a seen tour does not come back', (tester) async {
    await TourStore.complete('home');
    await _pump(tester, AppRoutes.home);
    expect(find.text('Дараах'), findsNothing);
  });

  testWidgets('Avatar tour: none without the loader (tests, storage errors)', (
    tester,
  ) async {
    TourStore.reset();
    await _pump(tester, AppRoutes.home);
    expect(find.text('Дараах'), findsNothing);
  });

  test('Avatar tour: load picks up what was already seen', () async {
    FlutterSecureStorage.setMockInitialValues({
      TourStore.keyFor('card'): 'true',
    });
    TourStore.reset();
    await TourStore.load();
    expect(TourStore.pending('card'), isFalse);
    expect(TourStore.pending('stocks'), isTrue);
  });
}
