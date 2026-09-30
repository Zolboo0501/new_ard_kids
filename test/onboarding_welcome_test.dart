import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_ard_kids/app/onboarding_store.dart';
import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/theme/app_theme.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    OnboardingStore.seen = false;
  });
  tearDown(() => OnboardingStore.seen = false);

  test('Introduction completion survives a new load', () async {
    await OnboardingStore.load();
    expect(OnboardingStore.seen, isFalse);
    await OnboardingStore.complete();
    OnboardingStore.seen = false;
    await OnboardingStore.load();
    expect(OnboardingStore.seen, isTrue);
  });

  for (final register in [true, false]) {
    testWidgets(register ? 'Start opens registration' : 'Sign in skips intro', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final router = AppRoutes.createRouter(initialLocation: AppRoutes.welcome);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
      );
      await tester.pumpAndSettle();
      if (register) {
        for (var i = 0; i < 2; i++) {
          expect(OnboardingStore.seen, isFalse);
          await tester.tap(find.text('Дараах'));
          await tester.pumpAndSettle();
        }
      }
      await tester.tap(find.text(register ? 'Эхлэх' : 'Нэвтрэх'));
      await tester.pumpAndSettle();
      expect(
        router.state.uri.toString(),
        register ? AppRoutes.register : AppRoutes.auth,
      );
      expect(find.text(register ? 'Код авах' : 'Үргэлжлүүлэх'), findsOneWidget);
      expect(OnboardingStore.seen, isTrue);
      await tester.pumpWidget(const SizedBox());
    });
  }
  for (final route in [
    AppRoutes.welcome,
    AppRoutes.ageGroup,
    AppRoutes.avatarPicker,
  ]) {
    testWidgets('Large text remains usable on $route', (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final router = AppRoutes.createRouter(initialLocation: route);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find
            .text(route == AppRoutes.welcome ? 'Дараах' : 'Үргэлжлүүлэх')
            .hitTestable(),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('Swipe, page indicators and skip work without early completion', (
    tester,
  ) async {
    final router = AppRoutes.createRouter(initialLocation: AppRoutes.welcome);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), const Offset(-700, 0));
    await tester.pumpAndSettle();
    expect(
      find.text('Мөнгөө юунд\nзарцуулсан бэ?').hitTestable(),
      findsOneWidget,
    );
    expect(OnboardingStore.seen, isFalse);
    await tester.tap(find.bySemanticsLabel('3 хуудасны 1'));
    await tester.pumpAndSettle();
    expect(find.text('Мөнгөө\nцуглуулаарай.').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Алгасах'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), AppRoutes.register);
    expect(OnboardingStore.seen, isTrue);
    await tester.pumpWidget(const SizedBox());
  });
  for (final size in [const Size(375, 667), const Size(1180, 820)]) {
    for (final dark in [false, true]) {
      testWidgets('Every slide fits $size dark=$dark', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        appBrightness.value = dark ? AppBrightness.dark : AppBrightness.light;
        addTearDown(() => appBrightness.value = AppBrightness.system);
        final router = AppRoutes.createRouter(
          initialLocation: AppRoutes.welcome,
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            routerConfig: router,
          ),
        );
        for (var i = 0; i < 3; i++) {
          await tester.pumpAndSettle();
          if (const bool.fromEnvironment('CAPTURE_SPLASH')) {
            await tester.runAsync(() async {
              for (final element in find.byType(Image).evaluate()) {
                await precacheImage((element.widget as Image).image, element);
              }
            });
            await tester.pumpAndSettle();
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile(
                '../.impeccable/review/splash-${size.width.toInt()}-$dark-$i.png',
              ),
            );
          }
          expect(tester.takeException(), isNull);
          expect(
            find.text(i == 2 ? 'Эхлэх' : 'Дараах').hitTestable(),
            findsOneWidget,
          );
          if (i < 2) await tester.tap(find.text('Дараах'));
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
