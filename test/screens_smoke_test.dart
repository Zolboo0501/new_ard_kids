import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/transfer/transfer_success_screen.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/ui.dart';

/// Pumps the app with a fresh router starting at [route] on a phone viewport.
Future<void> _pumpApp(WidgetTester tester, String route) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp.router(
      theme: buildAppTheme(),
      routerConfig: AppRoutes.createRouter(initialLocation: route),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
}

/// Pumps [route] on a phone-sized viewport and scrolls through it so layout
/// overflows and build errors anywhere on the page fail the test.
Future<void> _pumpRoute(WidgetTester tester, String route) async {
  await _pumpApp(tester, route);

  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty) {
    final main = scrollables.first;
    for (var i = 0; i < 6; i++) {
      await tester.drag(main, const Offset(0, -600), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
}

void main() {
  for (final route in AppRoutes.paths) {
    testWidgets('renders $route without errors', (tester) async {
      await _pumpRoute(tester, route);
    });
  }

  test('formatMnt groups thousands', () {
    expect(formatMnt(1280000), '₮1,280,000');
    expect(formatMnt(-15000, space: true), '-₮ 15,000');
    expect(formatMnt(5000, sign: true), '+₮5,000');
    expect(formatMnt(0), '₮0');
  });

  testWidgets('home account row opens savings account', (tester) async {
    await _pumpRoute(tester, AppRoutes.home);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildAppTheme(),
        routerConfig: AppRoutes.createRouter(initialLocation: AppRoutes.home),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Хадгаламжийн данс'));
    await tester.pumpAndSettle();
    expect(find.text('Миний зорилтууд'), findsOneWidget);
  });

  testWidgets('transfer submits and shows receipt', (tester) async {
    await _pumpApp(tester, AppRoutes.transfer);
    final button = find.widgetWithText(PrimaryButton, 'Гүйлгээ хийх');
    await tester.scrollUntilVisible(
      button,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(TransferSuccessScreen), findsOneWidget);
    expect(find.text('Гүйлгээ амжилттай!'), findsOneWidget);
    expect(find.text('Анар (Дүү)'), findsOneWidget);
  });
}
