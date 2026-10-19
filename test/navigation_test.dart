import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/home/presentation/widgets/floating_nav_bar.dart';
import 'package:new_ard_kids/features/home/presentation/screens/home_shell.dart';
import 'package:new_ard_kids/features/onboarding/presentation/screens/avatar_picker_screen.dart';
import 'package:new_ard_kids/features/transfer/presentation/screens/qr_scan_screen.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/slide_to_confirm.dart';
import 'package:new_ard_kids/widgets/app_tabs.dart';
import 'package:new_ard_kids/widgets/common.dart';

/// A bottom-bar tab, by its screen-reader label (the bar shows icons only).
Finder _navTab(String label) => find.descendant(
  of: find.byType(FloatingNavBar),
  matching: find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == label,
  ),
);

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

/// Finds the [Semantics] widget declaring [label] (no semantics tree needed).
Finder _semantic(String label) => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.label == label,
);

/// Location of the top-most screen, including ones opened with `push`.
String _location(GoRouter router) => router.state.uri.toString();

void main() {
  testWidgets('bottom nav switches branches and keeps tab state', (
    tester,
  ) async {
    final router = await _pumpApp(tester, AppRoutes.home);

    // Change state inside the Home branch.
    // Below the hero on a phone; scroll it into view first.
    await tester.ensureVisible(find.text('Карт'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Карт'));
    await tester.pumpAndSettle();
    expect(find.text('•••• 5521'), findsOneWidget);

    await tester.tap(_navTab('Профайл'));
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.profile);
    expect(find.text('Миний профайл'), findsOneWidget);

    await tester.tap(_navTab('Нүүр'));
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.home);
    expect(find.text('•••• 5521'), findsOneWidget);
  });

  testWidgets('sideways swipes move along Нүүр, QR, Чат and Профайл', (
    tester,
  ) async {
    final router = await _pumpApp(tester, AppRoutes.home);
    Future<void> swipe(double dx) async {
      // On the bar, clear of the balance carousel that keeps sideways drags.
      await tester.fling(find.byType(FloatingNavBar), Offset(dx, 0), 800);
      // The scanner animates forever, so pump past the transition instead
      // of settling.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
    }

    await swipe(-200);
    expect(_location(router), AppRoutes.qrScan);
    await swipe(-200);
    expect(_location(router), AppRoutes.chat);
    await swipe(-200);
    expect(_location(router), AppRoutes.profile);

    // Nothing after Профайл: a further left swipe stays put.
    await swipe(-200);
    expect(_location(router), AppRoutes.profile);

    await swipe(200);
    expect(_location(router), AppRoutes.chat);
    await swipe(200);
    expect(_location(router), AppRoutes.qrScan);
    await swipe(200);
    expect(_location(router), AppRoutes.home);
  });

  testWidgets('the bar\'s disc follows a sideways drag', (tester) async {
    final router = await _pumpApp(tester, AppRoutes.home);
    final bar = find.byType(FloatingNavBar);
    double discX() =>
        (tester
                    .widget<AnimatedAlign>(
                      find.descendant(
                        of: bar,
                        matching: find.byType(AnimatedAlign),
                      ),
                    )
                    .alignment
                as Alignment)
            .x;
    expect(discX(), -1);

    // A third of a tab to the left (a tab is half the 390pt width): the
    // disc sits that far towards QR while the finger is down (a tab is a
    // third of the disc's -1…1 travel across the four tabs).
    final gesture = await tester.startGesture(tester.getCenter(bar));
    await gesture.moveBy(const Offset(-20, 0)); // past the drag slop
    await gesture.moveBy(const Offset(-65, 0));
    await tester.pump();
    expect(discX(), closeTo(-1 + 2 / 9, 0.12));

    // Let go slowly short of halfway: the disc settles back on Нүүр.
    await tester.pump(const Duration(seconds: 1));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.home);
    expect(discX(), -1);

    // A slow drag past halfway moves on to QR.
    await tester.timedDrag(
      bar,
      const Offset(-160, 0),
      const Duration(seconds: 2),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(_location(router), AppRoutes.qrScan);
  });

  testWidgets('swiping Home\'s tab content moves through its tabs', (
    tester,
  ) async {
    final router = await _pumpApp(tester, AppRoutes.home);
    final content = find.byType(AppTabView);
    await tester.ensureVisible(content);
    await tester.pumpAndSettle();
    double pillX() =>
        (tester
                    .widget<AnimatedAlign>(
                      find.descendant(
                        of: find.byType(AppTabs),
                        matching: find.byType(AnimatedAlign),
                      ),
                    )
                    .alignment
                as Alignment)
            .x;
    expect(pillX(), -1);

    // The pill follows the finger: a third of a tab towards Нэхэмжлэх (a
    // tab is half the 390pt width).
    final gesture = await tester.startGesture(tester.getCenter(content));
    await gesture.moveBy(const Offset(-20, 0)); // past the drag slop
    await gesture.moveBy(const Offset(-65, 0));
    await tester.pump();
    expect(pillX(), closeTo(-1 + 1 / 3, 0.1));
    await tester.pump(const Duration(seconds: 1));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(pillX(), -1);

    // Flings move a tab at a time, and the page stays on Home.
    for (final x in [0.0, 1.0]) {
      await tester.fling(content, const Offset(-150, 0), 1000);
      await tester.pumpAndSettle();
      expect(pillX(), x);
      expect(_location(router), AppRoutes.home);
    }

    // Past Карт, the bar moves on to QR.
    await tester.fling(content, const Offset(-150, 0), 1000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(_location(router), AppRoutes.qrScan);
  });

  testWidgets('pushed screens cover the nav bar and pop back to the tab', (
    tester,
  ) async {
    final router = await _pumpApp(tester, AppRoutes.home);
    expect(find.byType(FloatingNavBar), findsOneWidget);

    // By its label: the 10–13 fox's button is a picture with the word drawn in.
    await tester.tap(_semantic('Гүйлгээ').first);
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.transferAmount);
    expect(find.byType(FloatingNavBar), findsNothing);

    await tester.tap(find.byType(CircleBackButton).first);
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.home);
    expect(find.byType(FloatingNavBar), findsOneWidget);
  });

  testWidgets('QR is a tab: the bar stays under the scanner', (tester) async {
    final router = await _pumpApp(tester, AppRoutes.home);
    await tester.tap(_semantic('QR уншуулах'));
    // The scanner line animates forever, so pump past the transition.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(_location(router), AppRoutes.qrScan);
    expect(find.byType(QrScanScreen), findsOneWidget);
    expect(find.byType(FloatingNavBar), findsOneWidget);
    // A tab, so no back button.
    expect(find.byType(CircleBackButton), findsNothing);
  });

  testWidgets('unlinked home keeps its state in the URL', (tester) async {
    final router = await _pumpApp(tester, AppRoutes.homeUnlinked);
    expect(find.text('Эцэг эхтэйгээ холбогдох'), findsOneWidget);
    expect(_location(router), AppRoutes.homeUnlinked);
  });

  testWidgets('notification card opens its screen', (tester) async {
    final router = await _pumpApp(tester, AppRoutes.notifications);
    await tester.tap(find.textContaining('PlayStation 5 Pro'));
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.savingsAccount);
  });

  testWidgets('profile avatar opens picker in edit mode and lands on Home', (
    tester,
  ) async {
    final router = await _pumpApp(tester, AppRoutes.profile);
    await tester.tap(_semantic('Аватар солих'));
    // AvatarPickerScreen's header has a dot that pulses forever, so pump the
    // route transition by hand instead of using pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final picker = tester.widget<AvatarPickerScreen>(
      find.byType(AvatarPickerScreen),
    );
    expect(picker.editing, isTrue);
    expect(find.text('Алхам 3/3'), findsNothing);

    final save = find.text('Аватараа хадгалах');
    await tester.ensureVisible(save);
    await tester.drag(find.byType(SlideToConfirm), const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.home);
    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('rewards account switches to the coin tab', (tester) async {
    await _pumpApp(tester, AppRoutes.rewardsAccount);
    expect(find.text('Урамшууллын данс'), findsOneWidget);
    expect(find.text('Нийт койны үлдэгдэл'), findsNothing);

    await tester.tap(find.text('Койн'));
    await tester.pumpAndSettle();
    expect(find.text('Койны данс'), findsOneWidget);
    expect(find.text('Нийт койны үлдэгдэл'), findsOneWidget);
    expect(find.text('Нийт үлдэгдэл'), findsNothing);
  });

  testWidgets('coin account route opens rewards on the coin tab', (
    tester,
  ) async {
    await _pumpApp(tester, AppRoutes.coinAccount);
    expect(find.text('Койны данс'), findsOneWidget);
    expect(find.text('Нийт койны үлдэгдэл'), findsOneWidget);

    await tester.tap(find.text('Урамшуулал'));
    await tester.pumpAndSettle();
    expect(find.text('Урамшууллын данс'), findsOneWidget);
    expect(find.text('Нийт үлдэгдэл'), findsOneWidget);
  });
}
