import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/home/presentation/widgets/floating_nav_bar.dart';
import 'package:new_ard_kids/features/home/presentation/screens/home_shell.dart';
import 'package:new_ard_kids/features/onboarding/presentation/screens/avatar_picker_screen.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/common.dart';

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
    await tester.tap(find.text('Карт'));
    await tester.pumpAndSettle();
    expect(find.text('Junior Card'), findsOneWidget);

    await tester.tap(find.text('Профайл'));
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.profile);
    expect(find.text('Миний профайл'), findsOneWidget);

    await tester.tap(find.text('Нүүр'));
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.home);
    expect(find.text('Junior Card'), findsOneWidget);
  });

  testWidgets('pushed screens cover the nav bar and pop back to the tab', (
    tester,
  ) async {
    final router = await _pumpApp(tester, AppRoutes.home);
    expect(find.byType(FloatingNavBar), findsOneWidget);

    await tester.tap(find.text('Гүйлгээ').first);
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.transfer);
    expect(find.byType(FloatingNavBar), findsNothing);

    await tester.tap(find.byType(CircleBackButton).first);
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.home);
    expect(find.byType(FloatingNavBar), findsOneWidget);
  });

  testWidgets('QR button opens the scanner above the shell', (tester) async {
    final router = await _pumpApp(tester, AppRoutes.home);
    await tester.tap(_semantic('QR уншуулах'));
    // The scanner line animates forever, so pump past the transition.
    await tester.pump(const Duration(milliseconds: 600));
    expect(_location(router), AppRoutes.qrScan);
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

  testWidgets('profile avatar opens picker in edit mode and returns', (
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
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.profile);
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
