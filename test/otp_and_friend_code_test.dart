import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/auth/friend_code_screen.dart';
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

    await tester.tap(find.text('Дахин илгээх'));
    await tester.pump();
    expect(find.text('01:00'), findsOneWidget);
  });

  testWidgets('Friend code: 6 digits confirm and open avatar picker', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 906 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(AppRoutes.friendCode));

    for (final d in ['7', '4', '9', '1', '2', '3']) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    await tester.tap(find.text('Баталгаажуулах'));
    await tester.pump();

    expect(find.text('Урилгын код: 749123'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(AvatarPickerScreen), findsOneWidget);
  });
}
