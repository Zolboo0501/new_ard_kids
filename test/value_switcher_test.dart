import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_ard_kids/widgets/app_tabs.dart';
import 'package:new_ard_kids/widgets/value_switcher.dart';

/// Flips [build]'s value back and forth faster than the transition, which
/// used to leave two outgoing children under one key ("Duplicate keys").
Future<void> _quickFlips(
  WidgetTester tester,
  Widget Function(int value) build,
) async {
  await tester.pumpWidget(build(0));
  for (final v in [1, 0, 1, 0, 1]) {
    await tester.pumpWidget(build(v));
    await tester.pump(const Duration(milliseconds: 40));
  }
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('ValueSwitcher survives quick back-and-forth changes', (
    tester,
  ) async {
    await _quickFlips(
      tester,
      (v) => MaterialApp(
        home: ValueSwitcher(
          value: v,
          duration: const Duration(milliseconds: 240),
          child: Text('text $v'),
        ),
      ),
    );
    expect(find.text('text 1'), findsOneWidget);
  });

  testWidgets('AppTabView survives quick back-and-forth tab switches', (
    tester,
  ) async {
    await _quickFlips(
      tester,
      (v) => MaterialApp(
        home: Scaffold(
          body: AppTabView(index: v, child: Text('pane $v')),
        ),
      ),
    );
    expect(find.text('pane 1'), findsOneWidget);
  });

  testWidgets('incoming is true only for the arriving child', (tester) async {
    final seen = <String, bool>{};
    Widget app(int v) => MaterialApp(
      home: ValueSwitcher(
        value: v,
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation, incoming) {
          final text = ((child as KeyedSubtree).child as Text).data!;
          seen[text] = incoming;
          return FadeTransition(opacity: animation, child: child);
        },
        child: Text('v$v'),
      ),
    );
    await tester.pumpWidget(app(0));
    await tester.pumpWidget(app(1));
    await tester.pump(const Duration(milliseconds: 50));
    expect(seen['v1'], isTrue);
    expect(seen['v0'], isFalse);
    await tester.pumpAndSettle();
  });
}
