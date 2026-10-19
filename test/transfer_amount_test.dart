import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/auth/presentation/widgets/submit_button.dart';
import 'package:new_ard_kids/features/transfer/data/money_request.dart';
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

SubmitButton _continue(WidgetTester tester) => tester.widget<SubmitButton>(
  find.widgetWithText(SubmitButton, 'Үргэлжлүүлэх'),
);

void main() {
  tearDown(MoneyRequests.reset);

  testWidgets('Transfer amount: keypad amount carries into the transfer', (
    tester,
  ) async {
    final router = await _pump(tester);
    expect(_continue(tester).dimmed, isTrue);
    // Dimmed, a tap stays on the amount.
    await tester.tap(find.text('Үргэлжлүүлэх'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), AppRoutes.transferAmount);

    for (final d in ['2', '5', '0', '0', '0']) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    expect(_continue(tester).dimmed, isFalse);

    await tester.tap(find.text('Үргэлжлүүлэх'));
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
    expect(_continue(tester).dimmed, isTrue);
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

    await tester.tap(find.text('Үргэлжлүүлэх'));
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

  testWidgets('Request money: a sent request waits at the top of the list', (
    tester,
  ) async {
    final router = await _pump(tester, AppRoutes.requestAmount);
    for (final d in ['3', '5', '0', '0', '0']) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    await tester.tap(find.text('Үргэлжлүүлэх'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Хүсэлт илгээх'));
    await tester.tap(find.text('Хүсэлт илгээх'));
    await tester.pumpAndSettle();

    // On the list, filtered to Хүлээгдэж буй, the new request first.
    expect(router.state.uri.toString(), AppRoutes.requestListPending);
    final cards = find.text('Долоо хоногийн өдрийн хоол');
    expect(cards, findsOneWidget);
    expect(
      tester.getTopLeft(cards).dy,
      lessThan(tester.getTopLeft(find.text('Сургуулийн аялал')).dy),
    );
    expect(find.bySemanticsLabel(RegExp('35,000')), findsWidgets);
    // Approved and declined requests are filtered out.
    expect(find.text('Чихэвч'), findsNothing);
    expect(MoneyRequests.all.first.status, RequestStatus.pending);
  });

  testWidgets('Request list: Цуцлах removes a pending request cleanly', (
    tester,
  ) async {
    // The total rolls to its new value inside the summary's IntrinsicHeight,
    // which used to throw.
    await _pump(tester, AppRoutes.requestListPending);
    expect(find.text('Сургуулийн аялал'), findsOneWidget);
    await tester.tap(find.text('Цуцлах'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Сургуулийн аялал'), findsNothing);
    expect(find.text('Энд хүсэлт алга'), findsOneWidget);
  });
}
