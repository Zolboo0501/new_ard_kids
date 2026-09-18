import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/app_tabs.dart';

/// Where the sliding pill currently sits on the -1..1 axis.
double _pillX(WidgetTester tester) {
  final align = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
  return (align.alignment as Alignment).x;
}

Future<void> _pump(
  WidgetTester tester, {
  required List<AppTab> tabs,
  required int index,
  required ValueChanged<int> onChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(
        body: Center(
          child: AppTabs(tabs: tabs, index: index, onChanged: onChanged),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('AppTabs: the pill sits over the selected tab', (tester) async {
    const tabs = [AppTab('Данс'), AppTab('Нэхэмжлэх'), AppTab('Карт')];

    await _pump(tester, tabs: tabs, index: 0, onChanged: (_) {});
    expect(_pillX(tester), -1);

    await _pump(tester, tabs: tabs, index: 1, onChanged: (_) {});
    await tester.pumpAndSettle();
    expect(_pillX(tester), 0);

    await _pump(tester, tabs: tabs, index: 2, onChanged: (_) {});
    await tester.pumpAndSettle();
    expect(_pillX(tester), 1);
  });

  testWidgets('AppTabs: tapping a tab reports its index', (tester) async {
    final taps = <int>[];
    await _pump(
      tester,
      tabs: const [AppTab('Нэвтрэх'), AppTab('Бүртгүүлэх')],
      index: 0,
      onChanged: taps.add,
    );

    await tester.tap(find.text('Бүртгүүлэх'));
    await tester.pump();
    expect(taps, [1]);

    await tester.tap(find.text('Нэвтрэх'));
    await tester.pump();
    expect(taps, [1, 0]);
  });

  testWidgets('AppTabs: a single tab does not divide by zero', (tester) async {
    await _pump(
      tester,
      tabs: const [AppTab('Бүгд')],
      index: 0,
      onChanged: (_) {},
    );

    expect(_pillX(tester), -1);
    expect(find.text('Бүгд'), findsOneWidget);
  });

  testWidgets('AppTabs: icons render alongside labels', (tester) async {
    await _pump(
      tester,
      tabs: const [
        AppTab('QR унших', icon: Icons.qr_code_scanner_rounded),
        AppTab('Миний QR', icon: Icons.qr_code_2_rounded),
      ],
      index: 0,
      onChanged: (_) {},
    );

    expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_2_rounded), findsOneWidget);
  });
}
