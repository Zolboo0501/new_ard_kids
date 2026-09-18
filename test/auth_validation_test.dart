import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/auth/presentation/screens/otp_screen.dart';
import 'package:new_ard_kids/theme/app_theme.dart';

/// Starts the real router at [location] so navigation behaves as in the app.
Widget _wrap(String location) => MaterialApp.router(
  theme: buildAppTheme(),
  routerConfig: AppRoutes.createRouter(initialLocation: location),
);

// The card has exactly two fields, in this order.
Finder get _nameField => find.byType(TextField).at(0);
Finder get _phoneField => find.byType(TextField).at(1);

String _textOf(WidgetTester tester, Finder field) =>
    tester.widget<TextField>(field).controller!.text;

/// The submit button sits below the default 800x600 test viewport, so give
/// the tests a phone-sized screen (as the keypad screens do).
void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 900 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Fills both fields with values that pass validation.
Future<void> _fillValid(WidgetTester tester) async {
  await tester.enterText(_nameField, 'Тэмүүлэн');
  await tester.enterText(_phoneField, '99112345');
  await tester.pump();
}

void main() {
  group('Нэвтрэх нэр', () {
    testWidgets('keeps letters, digits and _, dropping spaces and symbols', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(_wrap(AppRoutes.auth));

      await tester.enterText(_nameField, 'Тэмүүлэн 07! @#\$ ok_1 🎉');
      await tester.pump();

      expect(_textOf(tester, _nameField), 'Тэмүүлэн07ok_1');
    });

    testWidgets('caps the name at 20 characters', (tester) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(_wrap(AppRoutes.auth));

      await tester.enterText(_nameField, 'a' * 40);
      await tester.pump();

      expect(_textOf(tester, _nameField).length, 20);
    });

    testWidgets('an empty name blocks submit and shows the required message', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(_wrap(AppRoutes.auth));

      // Phone is valid, so the name is the only thing standing in the way.
      await tester.enterText(_phoneField, '99112345');
      await tester.tap(find.text('Үргэлжлүүлэх'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Нэвтрэх нэрээ оруулна уу.'), findsOneWidget);
      expect(find.byType(OtpScreen), findsNothing);
    });

    testWidgets('a one-character name shows the minimum-length message', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(_wrap(AppRoutes.auth));

      await tester.enterText(_nameField, 'Т');
      await tester.enterText(_phoneField, '99112345');
      await tester.tap(find.text('Үргэлжлүүлэх'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Нэвтрэх нэр дор хаяж 2 тэмдэгт байх ёстой.'),
        findsOneWidget,
      );
      expect(find.byType(OtpScreen), findsNothing);
    });

    testWidgets('a name starting with a digit is rejected', (tester) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(_wrap(AppRoutes.auth));

      await tester.enterText(_nameField, '1Тэмүүлэн');
      await tester.enterText(_phoneField, '99112345');
      await tester.tap(find.text('Үргэлжлүүлэх'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Нэвтрэх нэр үсгээр эхлэх ёстой.'), findsOneWidget);
      expect(find.byType(OtpScreen), findsNothing);
    });

    testWidgets('fixing the name clears its error', (tester) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(_wrap(AppRoutes.auth));

      await tester.tap(find.text('Үргэлжлүүлэх'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Нэвтрэх нэрээ оруулна уу.'), findsOneWidget);

      await tester.enterText(_nameField, 'Тэмүүлэн');
      // The message fades out, so wait for it to finish leaving the tree.
      await tester.pumpAndSettle();

      expect(find.text('Нэвтрэх нэрээ оруулна уу.'), findsNothing);
    });
  });

  group('Гар утасны дугаар', () {
    testWidgets('keeps digits only, capped at 8', (tester) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(_wrap(AppRoutes.auth));

      await tester.enterText(_phoneField, '99a1b2!3 45');
      await tester.pump();

      // '99a1b2!3 45' -> the seven digits it contains, under the 8 cap.
      expect(_textOf(tester, _phoneField), '9912345');
    });

    testWidgets('an empty phone shows the required message', (tester) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(_wrap(AppRoutes.auth));

      await tester.enterText(_nameField, 'Тэмүүлэн');
      await tester.tap(find.text('Үргэлжлүүлэх'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Гар утасны дугаараа оруулна уу.'), findsOneWidget);
      expect(find.byType(OtpScreen), findsNothing);
    });

    testWidgets('a short phone shows the length message, typing clears it', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(_wrap(AppRoutes.auth));

      await tester.enterText(_nameField, 'Тэмүүлэн');
      await tester.enterText(_phoneField, '9911');
      await tester.tap(find.text('Үргэлжлүүлэх'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Утасны дугаар 8 оронтой байх ёстой.'), findsOneWidget);

      await tester.enterText(_phoneField, '99112345');
      // The message fades out, so wait for it to finish leaving the tree.
      await tester.pumpAndSettle();

      expect(find.text('Утасны дугаар 8 оронтой байх ёстой.'), findsNothing);
    });
  });

  testWidgets('Auth: an empty form reports both fields at once', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(_wrap(AppRoutes.auth));

    await tester.tap(find.text('Үргэлжлүүлэх'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Нэвтрэх нэрээ оруулна уу.'), findsOneWidget);
    expect(find.text('Гар утасны дугаараа оруулна уу.'), findsOneWidget);
  });

  testWidgets('Auth: a valid form submits and opens OTP', (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(_wrap(AppRoutes.auth));

    await _fillValid(tester);
    await tester.tap(find.text('Үргэлжлүүлэх'));

    // Simulated send: 900ms to "sent", then 700ms before pushing OTP.
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Код илгээгдлээ!'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    // OtpScreen has a blinking cursor that never settles, so pump the route
    // transition by hand instead of using pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(OtpScreen), findsOneWidget);
  });
}
