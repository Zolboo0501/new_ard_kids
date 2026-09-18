import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/home/home_shell.dart';
import 'package:new_ard_kids/theme/app_theme.dart';

Future<void> _pumpShell(
  WidgetTester tester, {
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final router = AppRoutes.createRouter(initialLocation: AppRoutes.home);
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

/// Where the nav bar's selection pill currently sits on the -1..1 axis.
double _pillX(WidgetTester tester) {
  final align = tester.widget<AnimatedAlign>(
    find.descendant(
      of: find.byType(FloatingNavBar),
      matching: find.byType(AnimatedAlign),
    ),
  );
  return (align.alignment as Alignment).x;
}

/// Lowest opacity the shell body is being drawn at right now.
double _bodyOpacity(WidgetTester tester) {
  final layers = tester.widgetList<Opacity>(find.byType(Opacity));
  return layers.isEmpty
      ? 1
      : layers.map((o) => o.opacity).reduce((a, b) => a < b ? a : b);
}

void main() {
  testWidgets('Nav bar: the pill slides from Нүүр to Профайл', (tester) async {
    await _pumpShell(tester);
    expect(_pillX(tester), -1);

    await tester.tap(find.text('Профайл'));
    await tester.pumpAndSettle();
    expect(_pillX(tester), 1);

    await tester.tap(find.text('Нүүр'));
    await tester.pumpAndSettle();
    expect(_pillX(tester), -1);
  });

  testWidgets('Shell: the branch fades in rather than cutting', (tester) async {
    await _pumpShell(tester);
    expect(_bodyOpacity(tester), 1);

    await tester.tap(find.text('Профайл'));
    await tester.pump();
    // One frame in, the arriving branch is still on its way.
    await tester.pump(const Duration(milliseconds: 80));
    expect(_bodyOpacity(tester), lessThan(1));

    await tester.pumpAndSettle();
    expect(_bodyOpacity(tester), 1);
    expect(find.text('Миний профайл'), findsOneWidget);
  });

  testWidgets('Shell: reduced motion switches branches with no fade', (
    tester,
  ) async {
    await _pumpShell(tester, disableAnimations: true);

    await tester.tap(find.text('Профайл'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(_bodyOpacity(tester), 1);
    expect(find.text('Миний профайл'), findsOneWidget);
  });
}
