import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/accounts.dart';
import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/theme/app_theme.dart';

/// The account number the balance card is showing (not the invisible copies
/// that size its pill).
Finder _shown(String text, {required bool hidden}) => find.byWidgetPredicate(
  (w) => w is Text && w.data == text && w.key == ValueKey(hidden),
);

/// The pill's content box: the [Stack] holding the switcher's texts.
Rect _pill(WidgetTester tester, Finder text) => tester.getRect(
  find.ancestor(of: text, matching: find.byType(Stack)).first,
);

void main() {
  testWidgets(
    'Home: hiding the account number keeps the pill width and centres it',
    (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final router = AppRoutes.createRouter(initialLocation: AppRoutes.home);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
      );
      await tester.pumpAndSettle();

      final full = _shown(formatIban(Accounts.main), hidden: false);
      expect(full, findsOneWidget);
      final before = _pill(tester, full);

      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Данс, үлдэгдэл нуух',
        ),
      );
      await tester.pumpAndSettle();

      final masked = _shown(maskIban(Accounts.main), hidden: true);
      expect(masked, findsOneWidget);
      final after = _pill(tester, masked);
      expect(after.width, before.width);
      expect(tester.getCenter(masked).dx, closeTo(after.center.dx, 0.5));
    },
  );
}
