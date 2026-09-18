import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/auth/presentation/screens/friend_code_screen.dart';
import 'package:new_ard_kids/features/onboarding/avatar_picker_screen.dart';
import 'package:new_ard_kids/theme/app_theme.dart';

/// Starts the real router at [location] so navigation behaves as in the app.
Widget _wrap(String location, {Object? extra}) => MaterialApp.router(
  theme: buildAppTheme(),
  routerConfig: AppRoutes.createRouter(initialLocation: location, extra: extra),
);

void main() {
  testWidgets('OTP: keypad fills 4 digits, backspace, then opens friend code', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(AppRoutes.otp, extra: '99112345'));

    expect(find.textContaining('+976 9911 2345'), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);

    for (final d in ['5', '8', '2', '7', '1']) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    // Fifth digit is ignored.
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();
    await tester.tap(find.text('3').last);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Баталгаажуулах'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(FriendCodeScreen), findsOneWidget);
  });

  testWidgets('OTP: resend appears after countdown ends', (tester) async {
    await tester.pumpWidget(_wrap(AppRoutes.otp, extra: '99112345'));
    await tester.pump(const Duration(seconds: 61));
    expect(find.text('Дахин илгээх'), findsOneWidget);

    // The keypad is pinned to the bottom, so the code card above it may need
    // scrolling into view before the link can be tapped.
    await tester.ensureVisible(find.text('Дахин илгээх'));
    await tester.pump();
    await tester.tap(find.text('Дахин илгээх'));
    await tester.pump();
    expect(find.text('01:00'), findsOneWidget);
  });

  group('Найзаа нэмэх', () {
    void usePhoneViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(390 * 3, 906 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    testWidgets('a username sends the request and opens the avatar picker', (
      tester,
    ) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_wrap(AppRoutes.friendCode));
      await tester.pump(const Duration(milliseconds: 800));

      await tester.enterText(find.byType(TextField), 'temuulen_07');
      await tester.pump();
      await tester.tap(find.text('Хүсэлт илгээх'));
      await tester.pump();

      expect(
        find.text('temuulen_07 рүү найзын хүсэлт илгээлээ'),
        findsOneWidget,
      );

      // AvatarPickerScreen's header has a dot that pulses forever, so pump
      // the route transition by hand instead of using pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(AvatarPickerScreen), findsOneWidget);
    });

    testWidgets('the field keeps only username characters, capped at 20', (
      tester,
    ) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_wrap(AppRoutes.friendCode));
      await tester.pump(const Duration(milliseconds: 800));

      await tester.enterText(find.byType(TextField), 'Тэмүүлэн 07! @#\$ ok_1');
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'Тэмүүлэн07ok_1');

      await tester.enterText(find.byType(TextField), 'a' * 40);
      await tester.pump();
      expect(field.controller!.text.length, 20);
    });

    testWidgets('an empty username blocks the send and shows a message', (
      tester,
    ) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_wrap(AppRoutes.friendCode));
      await tester.pump(const Duration(milliseconds: 800));

      await tester.tap(find.text('Хүсэлт илгээх'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Найзынхаа нэвтрэх нэрийг оруулна уу.'), findsOneWidget);
      expect(find.byType(AvatarPickerScreen), findsNothing);
    });

    testWidgets('the field takes focus once the entrance has settled', (
      tester,
    ) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_wrap(AppRoutes.friendCode));

      // Mid-entrance the keyboard must not have been raised yet.
      await tester.pump(const Duration(milliseconds: 200));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.focusNode!.hasFocus, isFalse);

      // The entrance is 750ms.
      await tester.pump(const Duration(milliseconds: 700));
      expect(field.focusNode!.hasFocus, isTrue);
    });

    testWidgets('reduced motion focuses the field straight away', (
      tester,
    ) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _wrap(AppRoutes.friendCode),
        ),
      );
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.focusNode!.hasFocus, isTrue);
    });

    testWidgets('a username starting with a digit is rejected', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_wrap(AppRoutes.friendCode));
      await tester.pump(const Duration(milliseconds: 800));

      await tester.enterText(find.byType(TextField), '7temuulen');
      await tester.tap(find.text('Хүсэлт илгээх'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Нэвтрэх нэр үсгээр эхлэх ёстой.'), findsOneWidget);
      expect(find.byType(AvatarPickerScreen), findsNothing);
    });
  });
}
