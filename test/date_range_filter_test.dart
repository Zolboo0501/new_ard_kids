import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/home/presentation/screens/invoice_history_screen.dart';
import 'package:new_ard_kids/features/savings/presentation/screens/savings_history_screen.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/date_range_filter.dart';
import 'package:new_ard_kids/widgets/date_range_sheet.dart';

void main() {
  test('lastMonthsRange clamps to the end of a shorter month', () {
    final r = lastMonthsRange(3, now: DateTime(2026, 5, 31, 14));
    expect(r.start, DateTime(2026, 2, 28));
    expect(r.end, DateTime(2026, 5, 31));
    expect(formatRange(r), '2026.02.28 – 05.31');
  });

  testWidgets('Savings history: opens on this month, filters and clears', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = AppRoutes.createRouter(
      initialLocation: AppRoutes.savingsHistory,
    );
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pump();
    // Go explicitly too, in case the router starts somewhere else.
    router.go(AppRoutes.savingsHistory);
    await tester.pumpAndSettle();

    final list = find
        .descendant(
          of: find.byType(SavingsHistoryScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    Future<void> openSheet() async {
      await tester.tap(find.bySemanticsLabel('Хугацаагаар шүүх'));
      await tester.pumpAndSettle();
    }

    // Opens on this month: 53 days ago is never in it, and with no filter
    // there is nothing to clear.
    expect(find.text('Энэ сар'), findsOneWidget);
    expect(find.text('Зуны амралтын шагнал'), findsNothing);
    await openSheet();
    expect(find.byType(DateRangeSheet), findsOneWidget);
    expect(find.text('Цэвэрлэх'), findsNothing);

    // Picking another range shows Цэвэрлэх straight away.
    await tester.tap(find.text('Сүүлийн 3 сар'));
    await tester.pumpAndSettle();
    expect(find.text('Цэвэрлэх'), findsOneWidget);
    await tester.tap(find.text('Шүүх'));
    await tester.pumpAndSettle();

    expect(find.byType(DateRangeSheet), findsNothing);
    expect(find.text('Сүүлийн 3 сар'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Ээжээс хадгаламжид нэмэв'),
      200,
      scrollable: list,
    );
    // 130 days ago is outside the last 3 months.
    expect(find.text('Төрсөн өдрийн бэлэг'), findsNothing);

    // With a filter on, Цэвэрлэх goes back to this month.
    await openSheet();
    await tester.tap(find.text('Цэвэрлэх'));
    await tester.pumpAndSettle();
    expect(find.byType(DateRangeSheet), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Энэ сар'),
      -200,
      scrollable: list,
    );
    expect(find.text('Энэ сар'), findsOneWidget);
    expect(find.text('Зуны амралтын шагнал'), findsNothing);
  });

  testWidgets('Home invoices open the statement, which filters by date', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = AppRoutes.createRouter(initialLocation: AppRoutes.home);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pump();
    router.go(AppRoutes.home);
    await tester.pumpAndSettle();

    // Home's tab has no date filter, just the way to the statement.
    await tester.tap(find.text('Нэхэмжлэх'));
    await tester.pumpAndSettle();
    expect(find.byType(DateRangeFilterBar), findsNothing);
    final statement = find.text('Хуулга харах');
    await tester.scrollUntilVisible(
      statement,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(statement);
    await tester.pumpAndSettle();
    expect(find.byType(InvoiceHistoryScreen), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.invoiceHistory);

    // The statement opens on this month; 35 days ago is never in it.
    final list = find
        .descendant(
          of: find.byType(InvoiceHistoryScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    final bar = find.byType(DateRangeFilterBar);
    await tester.scrollUntilVisible(bar, 200, scrollable: list);
    await tester.pumpAndSettle();
    expect(find.text('Энэ сар'), findsOneWidget);
    expect(find.text('Сургуулийн аялалын төлбөр'), findsNothing);

    await tester.tap(bar);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сүүлийн 3 сар'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Шүүх'));
    await tester.pumpAndSettle();

    expect(find.text('Сүүлийн 3 сар'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Сургуулийн аялалын төлбөр'),
      200,
      scrollable: list,
    );
    expect(find.text('Сургуулийн аялалын төлбөр'), findsOneWidget);
  });

  test('describeRange names whole months and presets', () {
    final now = DateTime(2026, 9, 23);
    expect(
      describeRange(
        DateTimeRange(start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 31)),
        now: now,
      ),
      '8-р сар',
    );
    for (final n in [2, 3]) {
      expect(
        describeRange(lastMonthsRange(n, now: now), now: now),
        'Сүүлийн $n сар',
      );
    }
    expect(
      describeRange(
        DateTimeRange(start: DateTime(2026, 9, 1), end: now),
        now: now,
      ),
      'Энэ сар',
    );
    expect(
      formatRangeFriendly(
        DateTimeRange(start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 31)),
      ),
      '8-р сарын 1 – 31',
    );
  });
}
