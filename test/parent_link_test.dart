import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/theme/app_theme.dart';

Widget _wrap() => MaterialApp.router(
  theme: buildAppTheme(),
  routerConfig: AppRoutes.createRouter(initialLocation: AppRoutes.parentLink),
);

// The form has exactly two fields, in this order.
Finder get _phoneField => find.byType(TextField).at(0);
Finder get _registerField => find.byType(TextField).at(1);

String _textOf(WidgetTester tester, Finder field) =>
    tester.widget<TextField>(field).controller!.text;

Future<void> _pumpScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 3, 900 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_wrap());
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _submit(WidgetTester tester) async {
  // The screen is a lazy ListView, so the button has to be scrolled into
  // existence before it can be tapped.
  final button = find.text('Эцэг эх рүү хүсэлт илгээх');
  await tester.scrollUntilVisible(
    button,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
  await tester.tap(button);
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('Parent link: an empty form reports both fields at once', (
    tester,
  ) async {
    await _pumpScreen(tester);
    await _submit(tester);

    expect(find.text('Эцэг эхийн утасны дугаарыг оруулна уу.'), findsOneWidget);
    expect(find.text('Өөрийн регистрийн дугаарыг оруулна уу.'), findsOneWidget);
  });

  testWidgets('Parent link: a short phone shows the length message', (
    tester,
  ) async {
    await _pumpScreen(tester);

    await tester.enterText(_phoneField, '9911');
    await _submit(tester);

    expect(find.text('Утасны дугаар 8 оронтой байх ёстой.'), findsOneWidget);

    // Completing it clears the message once it has faded out.
    await tester.enterText(_phoneField, '99112345');
    await tester.pumpAndSettle();
    expect(find.text('Утасны дугаар 8 оронтой байх ёстой.'), findsNothing);
  });

  testWidgets('Parent link: a wrongly shaped register is rejected', (
    tester,
  ) async {
    await _pumpScreen(tester);

    await tester.enterText(_phoneField, '99112345');
    // Right length, wrong shape: digits where the two letters belong.
    await tester.enterText(_registerField, '1234567890');
    await _submit(tester);

    expect(
      find.text('Регистрийн дугаар 2 үсэг, 8 тооноос бүрдэнэ.'),
      findsOneWidget,
    );
  });

  testWidgets('Parent link: fields filter and cap their input', (tester) async {
    await _pumpScreen(tester);

    await tester.enterText(_phoneField, '99a1b2!3 4567');
    await tester.pump();
    expect(_textOf(tester, _phoneField), '99123456');

    // The register field upper-cases as you type and caps at 10.
    await tester.enterText(_registerField, 'ух12345678999');
    await tester.pump();
    expect(_textOf(tester, _registerField), 'УХ12345678');
  });
}
