import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/home/presentation/widgets/floating_nav_bar.dart';
import 'package:new_ard_kids/features/home/presentation/widgets/home_header.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/adaptive.dart';
import 'package:new_ard_kids/widgets/ui.dart';

Future<GoRouter> _pump(WidgetTester tester, String route, Size size) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final router = AppRoutes.createRouter(initialLocation: route);
  await tester.pumpWidget(
    MaterialApp.router(
      theme: buildAppTheme(),
      routerConfig: router,
      builder: AppScale.builder,
    ),
  );
  await tester.pump(const Duration(milliseconds: 800));
  return router;
}

/// The transfer screen's submit button, scrolled into view.
Future<Rect> _submitButton(WidgetTester tester) async {
  final button = find.widgetWithText(PrimaryButton, 'Гүйлгээ хийх');
  await tester.scrollUntilVisible(
    button,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  return tester.getRect(button);
}

const _proMax = Size(440, 956);
const _ipadPortrait = Size(820, 1180);
const _ipadLandscape = Size(1180, 820);

void main() {
  group('shell navigation', () {
    for (final (device, size) in [
      ('phones', _proMax),
      ('iPad', _ipadPortrait),
    ]) {
      testWidgets('$device use the floating bottom bar', (tester) async {
        await _pump(tester, AppRoutes.home, size);
        final bar = tester.getRect(find.byType(FloatingNavBar));
        expect(bar.bottom, size.height);
        expect(bar.center.dx, closeTo(size.width / 2, 1));
      });
    }

    testWidgets('the bar switches tabs and opens QR on iPad', (tester) async {
      final router = await _pump(tester, AppRoutes.home, _ipadLandscape);
      await tester.tap(find.text('Профайл'));
      await tester.pumpAndSettle();
      expect(find.text('Миний профайл'), findsOneWidget);

      await tester.tap(find.text('Нүүр'));
      await tester.pumpAndSettle();
      expect(find.text('Тэмүүлэн!'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.qr_code_scanner_rounded));
      await tester.pump(const Duration(milliseconds: 600));
      expect(router.state.uri.path, AppRoutes.qrScan);
    });
  });

  group('two panes', () {
    testWidgets('Home stays one column on a Pro Max', (tester) async {
      await _pump(tester, AppRoutes.home, _proMax);
      final balance = tester.getRect(find.text('ХАРИЛЦАХ ДАНС').first);
      final tabs = tester.getRect(find.text('Нэхэмжлэх').first);
      expect(tabs.top, greaterThan(balance.bottom));
    });

    testWidgets('Home puts the balance beside the tabs on iPad', (
      tester,
    ) async {
      await _pump(tester, AppRoutes.home, _ipadLandscape);
      final balance = tester.getRect(find.text('ХАРИЛЦАХ ДАНС').first);
      final tabs = tester.getRect(find.text('Нэхэмжлэх').first);
      expect(tabs.left, greaterThan(balance.right));
    });

    testWidgets('Profile puts settings beside the profile on iPad', (
      tester,
    ) async {
      await _pump(tester, AppRoutes.profile, _ipadLandscape);
      final name = tester.getRect(find.text('Бат-Ирээдүй Т.'));
      final settings = tester.getRect(find.text('Хувийн мэдээлэл'));
      expect(settings.left, greaterThan(name.right));
    });
  });

  group('page width', () {
    testWidgets('pushed screens fill the width on iPad', (tester) async {
      await _pump(tester, AppRoutes.transfer, _ipadLandscape);
      final button = await _submitButton(tester);
      // The screen's own 20pt gutters, drawn 1.2x.
      expect(button.width, closeTo(1180 - 40 * 1.2, 1));
      expect(button.center.dx, closeTo(1180 / 2, 1));
    });

    testWidgets('phones use the full width', (tester) async {
      await _pump(tester, AppRoutes.transfer, _proMax);
      final button = await _submitButton(tester);
      // Only the screen's own 20pt gutters.
      expect(button.width, 440 - 40);
    });
  });

  group('scale', () {
    test('only tablets are scaled up', () {
      expect(AppScale.factorFor(const Size(440, 956)), 1);
      expect(AppScale.factorFor(const Size(375, 667)), 1);
      expect(AppScale.factorFor(_ipadPortrait), 1.2);
      expect(AppScale.factorFor(_ipadLandscape), 1.2);
      expect(AppScale.factorFor(const Size(1032, 1376)), 1.3);
    });

    testWidgets('text is drawn bigger on iPad than on a phone', (tester) async {
      await _pump(tester, AppRoutes.home, _proMax);
      final phone = tester.getRect(find.text('Тэмүүлэн!')).height;
      await _pump(tester, AppRoutes.home, _ipadPortrait);
      final ipad = tester.getRect(find.text('Тэмүүлэн!')).height;
      expect(ipad, closeTo(phone * 1.2, 0.5));
    });
  });

  testWidgets('the scale fills the window under loose constraints', (
    tester,
  ) async {
    // AppLoader fades the app in inside a Stack, which loosens constraints.
    tester.view.physicalSize = _ipadPortrait * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Stack(
        alignment: Alignment.center,
        children: [
          MaterialApp.router(
            theme: buildAppTheme(),
            routerConfig: AppRoutes.createRouter(
              initialLocation: AppRoutes.home,
            ),
            builder: AppScale.builder,
          ),
        ],
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));
    final header = tester.getRect(find.byType(HomeHeader));
    expect(header.left, 0);
    expect(header.width, closeTo(_ipadPortrait.width, 0.5));
  });

  test('AppLayout.centered only grows padding past the max width', () {
    const base = EdgeInsets.fromLTRB(16, 8, 16, 24);
    expect(AppLayout.centered(base, 1000), base);
    expect(AppLayout.centered(base, 440, maxWidth: 560), base);
    final wide = AppLayout.centered(base, 1000, maxWidth: 560);
    expect(1000 - wide.left - wide.right, 560);
    expect(wide.top, 8);
    expect(wide.bottom, 24);
  });
}
