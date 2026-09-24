import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_ard_kids/features/accounts/presentation/widgets/copy_account_number.dart';
import 'package:new_ard_kids/widgets/ui.dart';

String _shown(WidgetTester tester) =>
    tester.widget<RichText>(find.byType(RichText)).text.toPlainText();

/// The label screen readers hear for the rolling display.
Finder _labelled(String label) => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.label == label,
);

Widget _app(Widget child) => MaterialApp(home: Center(child: child));

void main() {
  testWidgets('animateFrom rolls the digits in and lands on the amount', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const BalanceText(50000, animateFrom: 0, size: 20)),
    );
    // Screen readers get the final amount straight away, not each step.
    expect(_labelled('₮50,000.00'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
    expect(_labelled('₮50,000.00'), findsOneWidget);
  });

  testWidgets('animate alone shows the first value at rest', (tester) async {
    await tester.pumpWidget(
      _app(const BalanceText(50000, animate: true, size: 20)),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(_labelled('₮50,000.00'), findsOneWidget);
  });

  testWidgets('a new amount rolls to it, adding a digit place', (tester) async {
    await tester.pumpWidget(
      _app(const BalanceText(9999, animate: true, size: 20)),
    );
    await tester.pumpWidget(
      _app(const BalanceText(10000, animate: true, size: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpAndSettle();
    expect(_labelled('₮10,000.00'), findsOneWidget);
  });

  testWidgets('reduced motion skips the roll', (tester) async {
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

  testWidgets('the eye hides the account number and balance together', (
    tester,
  ) async {
    var hidden = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                CopyAccountNumber(
                  number: 'MN320460005049821900',
                  hidden: hidden,
                  onToggleHidden: () => setState(() => hidden = !hidden),
                ),
                HideableBalance(
                  hidden: hidden,
                  balance: const BalanceText(567930, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('MN32 0460 0050 4982 1900'), findsOneWidget);
    expect(find.text('₮567,930.00'), findsOneWidget);

    await tester.tap(_labelled('Данс, үлдэгдэл нуух'));
    await tester.pumpAndSettle();
    expect(find.text('MN32 •••• •••• •••• 1900'), findsOneWidget);
    expect(find.text('MN32 0460 0050 4982 1900'), findsNothing);
    expect(find.text('••••••••'), findsOneWidget);
    expect(find.text('₮567,930.00'), findsNothing);

    await tester.tap(_labelled('Данс, үлдэгдэл харах'));
    await tester.pumpAndSettle();
    expect(find.text('MN32 0460 0050 4982 1900'), findsOneWidget);
    expect(find.text('₮567,930.00'), findsOneWidget);
  });

  testWidgets('₮ matches the digits and the decimals are smaller and grey', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const BalanceText(567930, size: 30)));
    final root = tester.widget<RichText>(find.byType(RichText)).text;
    // Each piece of text with the size it is drawn at (inherited if unset).
    final pieces = <(String, double)>[];
    void walk(InlineSpan span, double inherited) {
      final size = span.style?.fontSize ?? inherited;
      if (span is TextSpan) {
        if (span.text != null) pieces.add((span.text!, size));
        for (final child in span.children ?? const <InlineSpan>[]) {
          walk(child, size);
        }
      }
    }

    walk(root, 0);
    final decimals = _decimalsSpan(root);
    expect(decimals.style!.color, BalanceText.decimalsColor);
    expect(pieces, [
      ('₮', 30.0),
      ('567,930', 30.0),
      ('.00', 30 * BalanceText.decimalsScale),
    ]);
  });
}

/// The span holding the `.00`.
TextSpan _decimalsSpan(InlineSpan root) {
  TextSpan? found;
  root.visitChildren((span) {
    if (span is TextSpan && (span.text?.startsWith('.') ?? false)) {
      found = span;
      return false;
    }
    return true;
  });
  return found!;
}
