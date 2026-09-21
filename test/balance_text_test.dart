import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_ard_kids/widgets/ui.dart';

String _shown(WidgetTester tester) =>
    tester.widget<RichText>(find.byType(RichText)).text.toPlainText();

Widget _app(Widget child) => MaterialApp(home: Center(child: child));

void main() {
  testWidgets('animateFrom counts the first display up to the amount', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const BalanceText(50000, animateFrom: 0, size: 20)),
    );
    expect(_shown(tester), '₮0.00');

    await tester.pump(const Duration(milliseconds: 150));
    expect(_shown(tester), isNot('₮0.00'));
    expect(_shown(tester), isNot('₮50,000.00'));

    await tester.pumpAndSettle();
    expect(_shown(tester), '₮50,000.00');
  });

  testWidgets('animate alone shows the first value straight away', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const BalanceText(50000, animate: true, size: 20)),
    );
    expect(_shown(tester), '₮50,000.00');
  });

  testWidgets('reduced motion skips the count', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const Center(
            child: BalanceText(50000, animateFrom: 0, size: 20),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(_shown(tester), '₮50,000.00');
  });
}
