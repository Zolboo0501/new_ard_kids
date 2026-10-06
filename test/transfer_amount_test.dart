import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/ui.dart';

Future<GoRouter> _pump(
  WidgetTester tester, [
  String location = AppRoutes.transferAmount,
]) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final router = AppRoutes.createRouter(initialLocation: location);
  await tester.pumpWidget(
    MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
  );
  await tester.pumpAndSettle();
  return router;
}

PrimaryButton _continue(WidgetTester tester) => tester.widget<PrimaryButton>(
  find.widgetWithText(PrimaryButton, 'Үргэлжлүүлэх'),
);

void main() {
  testWidgets('Transfer amount: keypad amount carries into the transfer', (
    tester,
  ) async {
    final router = await _pump(tester);
    expect(_continue(tester).onPressed, isNull);

    for (final d in ['2', '5', '0', '0', '0']) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    expect(_continue(tester).onPressed, isNotNull);

    await tester.tap(find.widgetWithText(PrimaryButton, 'Үргэлжлүүлэх'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), AppRoutes.transfer);
    expect(find.bySemanticsLabel(RegExp('25,000')), findsWidgets);
  });

  testWidgets('Transfer amount: over today\'s limit cannot continue', (
    tester,
  ) async {
    await _pump(tester);
    for (final d in ['9', '0', '0', '0', '0']) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    expect(find.textContaining('Өнөөдрийн үлдэгдэл эрх'), findsOneWidget);
    expect(_continue(tester).onPressed, isNull);
  });

  testWidgets('Request amount: keypad amount carries into the request', (
    tester,
  ) async {
    final router = await _pump(tester, AppRoutes.requestAmount);
    // No limit applies to asking a parent.
    for (final d in ['9', '0', '0', '0', '0']) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    expect(find.textContaining('Өнөөдрийн үлдэгдэл эрх'), findsNothing);

    await tester.tap(find.widgetWithText(PrimaryButton, 'Үргэлжлүүлэх'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), AppRoutes.requestMoney);
    expect(find.text('Хүсэх дүн'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('90,000')), findsWidgets);
  });

  testWidgets('Request amount: history button opens the request list', (
    tester,
  ) async {
    final router = await _pump(tester, AppRoutes.requestAmount);
    await tester.tap(find.bySemanticsLabel('Хүсэлтийн жагсаалт'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), AppRoutes.requestList);
  });

  testWidgets('Request money: history button opens the request list', (
    tester,
  ) async {
    final router = await _pump(tester, AppRoutes.requestMoney);
    await tester.tap(find.widgetWithText(SoftButton, 'Хүсэлтийн түүх'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), AppRoutes.requestList);
  });
}
