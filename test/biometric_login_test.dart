import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_ard_kids/app/biometrics.dart';
import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/auth/presentation/screens/auth_screen.dart';
import 'package:new_ard_kids/theme/app_theme.dart';

class _FakeBiometrics implements Biometrics {
  _FakeBiometrics({
    this.kind = BiometricKind.face,
    this.sensor = true,
    this.match = true,
  });

  BiometricKind? kind;
  final bool sensor;
  bool match;
  int prompts = 0;

  @override
  Future<BiometricKind?> available() async => kind;

  @override
  Future<bool> hasSensor() async => sensor;

  @override
  Future<BiometricResult> authenticate(String reason) async {
    prompts++;
    if (kind == null) return BiometricResult.notEnrolled;
    return match ? BiometricResult.success : BiometricResult.failed;
  }
}

void main() {
  final realBiometrics = Biometrics.instance;

  setUp(() {
    appBiometricLogin.value = false;
    AuthScreen.biometricPrompted = false;
    FlutterSecureStorage.setMockInitialValues({});
  });
  tearDown(() {
    appBiometricLogin.value = false;
    Biometrics.instance = realBiometrics;
  });

  /// Lets transitions and scans finish. The onboarding Header's step dot
  /// pulses forever, so those screens can't use `pumpAndSettle`.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  Future<GoRouter> pumpAt(
    WidgetTester tester,
    String location, {
    bool pulsing = false,
  }) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = AppRoutes.createRouter(initialLocation: location);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    pulsing ? await settle(tester) : await tester.pumpAndSettle();
    return router;
  }

  Finder biometricSwitch() => find.byType(Switch).first;

  testWidgets('Security: turning biometric sign-in on needs a scan', (
    tester,
  ) async {
    final fake = _FakeBiometrics();
    Biometrics.instance = fake;
    await pumpAt(tester, AppRoutes.security);

    expect(find.text('Face ID-аар нэвтрэх'), findsOneWidget);
    expect(tester.widget<Switch>(biometricSwitch()).value, isFalse);

    await tester.tap(biometricSwitch());
    await tester.pumpAndSettle();
    expect(fake.prompts, 1);
    expect(appBiometricLogin.value, isTrue);
    expect(tester.widget<Switch>(biometricSwitch()).value, isTrue);
    expect(
      await const FlutterSecureStorage().read(key: 'biometric_login'),
      'true',
    );

    await tester.tap(biometricSwitch());
    await tester.pumpAndSettle();
    expect(fake.prompts, 1, reason: 'turning it off needs no scan');
    expect(appBiometricLogin.value, isFalse);
  });

  testWidgets('Security: a failed scan leaves biometric sign-in off', (
    tester,
  ) async {
    Biometrics.instance = _FakeBiometrics(match: false);
    await pumpAt(tester, AppRoutes.security);

    await tester.tap(biometricSwitch());
    await tester.pumpAndSettle();
    expect(appBiometricLogin.value, isFalse);
    expect(find.text('Баталгаажуулалт амжилтгүй боллоо'), findsOneWidget);
  });

  testWidgets(
    'Security: a sensor with nothing enrolled explains how to enrol',
    (tester) async {
      final fake = _FakeBiometrics(kind: null);
      Biometrics.instance = fake;
      await pumpAt(tester, AppRoutes.security);

      expect(
        find.text('Эхлээд утасныхаа тохиргооноос бүртгүүлнэ үү'),
        findsOneWidget,
      );
      await tester.tap(biometricSwitch());
      await tester.pumpAndSettle();
      expect(appBiometricLogin.value, isFalse);
      expect(find.text(BiometricResult.notEnrolled.message!), findsOneWidget);

      // Enrolled in the phone's settings, then back to the app.
      fake.kind = BiometricKind.face;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('Face ID-аар нэвтрэх'), findsOneWidget);

      await tester.tap(biometricSwitch());
      await tester.pumpAndSettle();
      expect(appBiometricLogin.value, isTrue);
    },
  );

  testWidgets('Security: no sensor disables the switch', (tester) async {
    Biometrics.instance = _FakeBiometrics(kind: null, sensor: false);
    await pumpAt(tester, AppRoutes.security);

    expect(find.text('Энэ төхөөрөмж дэмжихгүй байна'), findsOneWidget);
    expect(tester.widget<Switch>(biometricSwitch()).onChanged, isNull);
  });

  testWidgets('Sign-in: no biometric button while the setting is off', (
    tester,
  ) async {
    final fake = _FakeBiometrics();
    Biometrics.instance = fake;
    await pumpAt(tester, AppRoutes.auth);

    expect(find.text('Face ID-аар нэвтрэх'), findsNothing);
    expect(fake.prompts, 0);
  });

  testWidgets('Sign-in: prompts once on open and signs in on a match', (
    tester,
  ) async {
    appBiometricLogin.value = true;
    final fake = _FakeBiometrics(kind: BiometricKind.fingerprint);
    Biometrics.instance = fake;
    final router = await pumpAt(tester, AppRoutes.auth);

    expect(fake.prompts, 1);
    expect(router.state.uri.path, AppRoutes.home);
  });

  testWidgets('Sign-in: a cancelled prompt leaves the button to retry', (
    tester,
  ) async {
    appBiometricLogin.value = true;
    final fake = _FakeBiometrics(kind: BiometricKind.fingerprint, match: false);
    Biometrics.instance = fake;
    final router = await pumpAt(tester, AppRoutes.auth);

    expect(fake.prompts, 1);
    expect(router.state.uri.path, AppRoutes.auth);

    fake.match = true;
    await tester.tap(find.text('Хурууны хээгээр нэвтрэх'));
    await tester.pumpAndSettle();
    expect(fake.prompts, 2);
    expect(router.state.uri.path, AppRoutes.home);
  });

  testWidgets('Sign-in: only the first screen of a launch prompts by itself', (
    tester,
  ) async {
    appBiometricLogin.value = true;
    AuthScreen.biometricPrompted = true;
    final fake = _FakeBiometrics();
    Biometrics.instance = fake;
    await pumpAt(tester, AppRoutes.auth);

    expect(fake.prompts, 0);
    expect(find.text('Face ID-аар нэвтрэх'), findsOneWidget);
  });

  testWidgets('Register: confirming turns Face ID on and moves to the parent', (
    tester,
  ) async {
    final fake = _FakeBiometrics();
    Biometrics.instance = fake;
    final router = await pumpAt(
      tester,
      AppRoutes.biometricSetup,
      pulsing: true,
    );

    expect(find.text('Алхам 5/6'), findsOneWidget);
    expect(find.text('Face ID-аар нэвтрэх үү?'), findsOneWidget);

    await tester.tap(find.text('Face ID идэвхжүүлэх'));
    await settle(tester);
    expect(fake.prompts, 1);
    expect(appBiometricLogin.value, isTrue);
    expect(
      await const FlutterSecureStorage().read(key: 'biometric_login'),
      'true',
    );
    expect(router.state.uri.toString(), AppRoutes.parentLinkOnboarding);
  });

  testWidgets('Register: a failed scan stays on the step', (tester) async {
    Biometrics.instance = _FakeBiometrics(match: false);
    final router = await pumpAt(
      tester,
      AppRoutes.biometricSetup,
      pulsing: true,
    );

    await tester.tap(find.text('Face ID идэвхжүүлэх'));
    await settle(tester);
    expect(appBiometricLogin.value, isFalse);
    expect(find.text(BiometricResult.failed.message!), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.biometricSetup);
  });

  testWidgets('Register: "Дараа болъё" skips without a scan', (tester) async {
    final fake = _FakeBiometrics();
    Biometrics.instance = fake;
    final router = await pumpAt(
      tester,
      AppRoutes.biometricSetup,
      pulsing: true,
    );

    await tester.tap(find.text('Дараа болъё'));
    await settle(tester);
    expect(fake.prompts, 0);
    expect(appBiometricLogin.value, isFalse);
    expect(router.state.uri.toString(), AppRoutes.parentLinkOnboarding);
  });

  testWidgets('Register: the avatar step leads to the biometric step', (
    tester,
  ) async {
    Biometrics.instance = _FakeBiometrics();
    final router = await pumpAt(tester, AppRoutes.avatarPicker, pulsing: true);

    await tester.tap(find.text('Сонгосон найзаа батлах '));
    await settle(tester);
    expect(router.state.uri.path, AppRoutes.biometricSetup);
  });

  testWidgets('Register: no sensor skips straight to the parent link', (
    tester,
  ) async {
    Biometrics.instance = _FakeBiometrics(kind: null, sensor: false);
    final router = await pumpAt(tester, AppRoutes.avatarPicker, pulsing: true);

    await tester.tap(find.text('Сонгосон найзаа батлах '));
    await settle(tester);
    expect(router.state.uri.toString(), AppRoutes.parentLinkOnboarding);
  });
}
