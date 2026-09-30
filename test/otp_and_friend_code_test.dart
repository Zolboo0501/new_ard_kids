import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/biometrics.dart';
import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/app/age_group.dart';
import 'package:new_ard_kids/app/avatar.dart';
import 'package:new_ard_kids/features/onboarding/presentation/screens/age_group_screen.dart';
import 'package:new_ard_kids/features/onboarding/presentation/screens/avatar_picker_screen.dart';
import 'package:new_ard_kids/features/onboarding/presentation/screens/parent_link_screen.dart';
import 'package:new_ard_kids/theme/app_theme.dart';

/// Starts the real router at [location] so navigation behaves as in the app.
Widget _wrap(String location, {Object? extra}) => MaterialApp.router(
  theme: buildAppTheme(),
  routerConfig: AppRoutes.createRouter(initialLocation: location, extra: extra),
);

/// A phone without a biometric sensor, so registration skips that step.
class _NoSensor implements Biometrics {
  @override
  Future<BiometricKind?> available() async => null;
  @override
  Future<bool> hasSensor() async => false;
  @override
  Future<BiometricResult> authenticate(String reason) async =>
      BiometricResult.failed;
}

void main() {
  testWidgets(
    'OTP: keypad fills 4 digits, backspace, then opens the age step',
    (tester) async {
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

      expect(find.byType(AgeGroupScreen), findsOneWidget);
    },
  );

  testWidgets('Age: changing it from Profile saves and returns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    FlutterSecureStorage.setMockInitialValues({});
    addTearDown(() {
      appAgeGroup.value = AgeGroup.tween;
      appAvatar.value = AppAvatar.fox;
    });
    final router = AppRoutes.createRouter(initialLocation: AppRoutes.profile);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Нас'));
    await tester.tap(find.text('Нас'));
    await tester.pumpAndSettle();
    // Opened from Profile: no step counter, the saved age is picked, and
    // saving waits for a different one.
    expect(find.text('Алхам 3/7'), findsNothing);
    await tester.tap(find.text('Хадгалах'));
    await tester.pumpAndSettle();
    expect(find.byType(AgeGroupScreen), findsOneWidget);

    await tester.tap(find.text('14–18 нас'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Хадгалах'));
    await tester.pumpAndSettle();

    expect(appAgeGroup.value, AgeGroup.teen);
    expect(
      await const FlutterSecureStorage().read(key: 'app_age_group'),
      'teen',
    );
    expect(router.state.uri.path, AppRoutes.profile);
    expect(find.text('14–18 нас'), findsOneWidget);
  });

  testWidgets('Age: continue waits for a choice, saves it, opens the avatars', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    FlutterSecureStorage.setMockInitialValues({});
    appAvatar.value = AppAvatar.penguin;
    addTearDown(() {
      appAgeGroup.value = AgeGroup.tween;
      appAvatar.value = AppAvatar.fox;
    });

    await tester.pumpWidget(_wrap(AppRoutes.ageGroup));
    await tester.pumpAndSettle();
    expect(find.text('Алхам 3/7'), findsOneWidget);

    // Nothing picked yet: the button does nothing.
    await tester.tap(find.text('Үргэлжлүүлэх'));
    await tester.pumpAndSettle();
    expect(find.byType(AvatarPickerScreen), findsNothing);

    await tester.tap(find.text('10–13 нас'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Үргэлжлүүлэх'));
    await tester.pumpAndSettle();

    expect(appAgeGroup.value, AgeGroup.tween);
    expect(
      await const FlutterSecureStorage().read(key: 'app_age_group'),
      'tween',
    );
    // The penguin is only in the kids' set; the older sets have the cat.
    expect(appAvatar.value, AppAvatar.cat);
    expect(find.byType(AvatarPickerScreen), findsOneWidget);
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

    testWidgets('a username sends the request and moves on to sign-in setup', (
      tester,
    ) async {
      usePhoneViewport(tester);
      final real = Biometrics.instance;
      Biometrics.instance = _NoSensor();
      addTearDown(() => Biometrics.instance = real);
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

      // Without a biometric sensor it goes straight on to the parent link.
      await tester.pumpAndSettle();
      expect(find.byType(ParentLinkScreen), findsOneWidget);
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
