import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/accounts/card_screen.dart';
import 'package:new_ard_kids/theme/app_theme.dart';

void main() {
  testWidgets('Home: the active card opens Миний карт', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = AppRoutes.createRouter(initialLocation: AppRoutes.home);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    router.go(AppRoutes.home);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Карт'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Junior Card'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.card);
    expect(find.byType(CardScreen), findsOneWidget);
    expect(find.text('•••• •••• •••• 5521'), findsNWidgets(2));

    // Дугаар харах shows the full number on the card and in the details.
    await tester.tap(find.text('Дугаар харах'));
    await tester.pumpAndSettle();
    expect(find.text('4000 1234 5678 5521'), findsNWidgets(2));

    // Түр хаах freezes the card; Карт нээх turns it back on.
    await tester.tap(find.text('Түр хаах'));
    await tester.pumpAndSettle();
    expect(find.text('Түр хаасан'), findsWidgets);
    expect(find.text('Карт нээх'), findsOneWidget);
    await tester.tap(find.text('Карт нээх'));
    await tester.pumpAndSettle();
    expect(find.text('Идэвхтэй'), findsOneWidget);
  });
}
