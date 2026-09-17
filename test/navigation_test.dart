import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/home/home_shell.dart';
import 'package:new_ard_kids/features/onboarding/avatar_picker_screen.dart';
import 'package:new_ard_kids/theme/app_theme.dart';

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

String _location(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.toString();

void main() {
  testWidgets('bottom nav switches branches and keeps tab state', (
    tester,
  ) async {
    final router = await _pumpApp(tester, AppRoutes.home);

    // Change state inside the Home branch.
    await tester.tap(find.text('Карт'));
    await tester.pumpAndSettle();
    expect(find.text('PocketPal Junior Card'), findsOneWidget);

    await tester.tap(find.text('Профайл'));
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.profile);
    expect(find.text('Миний профайл'), findsOneWidget);

    await tester.tap(find.text('Нүүр'));
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.home);
    expect(find.text('PocketPal Junior Card'), findsOneWidget);
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

    await tester.tap(find.bySemanticsLabel('Буцах').first);
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.home);
    expect(find.byType(FloatingNavBar), findsOneWidget);
  });

  testWidgets('QR button opens the scanner above the shell', (tester) async {
    final router = await _pumpApp(tester, AppRoutes.home);
    await tester.tap(find.bySemanticsLabel('QR уншуулах'));
    await tester.pumpAndSettle();
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
    await tester.tap(find.bySemanticsLabel('Аватар солих'));
    await tester.pumpAndSettle();

    final picker = tester.widget<AvatarPickerScreen>(
      find.byType(AvatarPickerScreen),
    );
    expect(picker.editing, isTrue);
    expect(find.text('Алхам 3/3'), findsNothing);

    final save = find.text('Аватараа хадгалах ✨');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.profile);
    expect(find.byType(HomeShell), findsOneWidget);
  });
}
