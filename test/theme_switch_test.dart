import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/main.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/theme/theme_store.dart';
import 'package:new_ard_kids/widgets/app_tabs.dart';

/// Every text, icon and box color currently in the tree.
Set<Color> _colors(WidgetTester tester) => {
  for (final w in tester.allWidgets)
    ?switch (w) {
      Text(:final style?) => style.color,
      Icon(:final color) => color,
      DecoratedBox(decoration: BoxDecoration(:final color)) => color,
      Container(:final BoxDecoration decoration) => decoration.color,
      _ => null,
    },
};

void main() {
  void reset() {
    appThemeChoice.value = AppThemeChoice.sky;
    appBrightness.value = AppBrightness.light;
  }

  setUp(() {
    reset();
    FlutterSecureStorage.setMockInitialValues({});
  });
  tearDown(() {
    appThemeChoice.value = AppThemeChoice.sky;
    appBrightness.value = AppBrightness.system;
  });

  test('Every token follows the light / dark mode', () {
    final light = (AppColors.surface, AppColors.slate900, AppColors.sky500);
    appBrightness.value = AppBrightness.dark;
    final dark = (AppColors.surface, AppColors.slate900, AppColors.sky500);

    expect(light.$1, isNot(dark.$1));
    expect(light.$2, isNot(dark.$2));
    expect(light.$3, isNot(dark.$3));
    // Text is dark on the light canvas and light on the dark one.
    expect(light.$2.computeLuminance(), lessThan(0.1));
    expect(dark.$2.computeLuminance(), greaterThan(0.9));
    expect(dark.$1.computeLuminance(), lessThan(0.01));
  });

  test('Accent text and secondary text stay readable in both modes', () {
    double contrast(Color a, Color b) {
      final (la, lb) = (a.computeLuminance(), b.computeLuminance());
      return (la > lb ? la + 0.05 : lb + 0.05) /
          (la > lb ? lb + 0.05 : la + 0.05);
    }

    for (final mode in [AppBrightness.light, AppBrightness.dark]) {
      appBrightness.value = mode;
      for (final choice in AppThemeChoice.values) {
        appThemeChoice.value = choice;
        // The fills are soft: the text on them is large and bold (buttons)
        // or a control, where 3:1 is the bar.
        expect(
          contrast(AppColors.onAccent, AppColors.sky500),
          greaterThanOrEqualTo(3),
          reason: '$choice on $mode',
        );
      }
      expect(contrast(AppColors.slate400, AppColors.card), greaterThan(4.5));
      expect(contrast(AppColors.slate500, AppColors.surface), greaterThan(4.5));
    }
  });

  test('Tab styles follow the accent', () {
    expect(AppTabsStyle.card.dotColor, AppPalette.of(AppThemeChoice.sky).c500);
    appThemeChoice.value = AppThemeChoice.pink;
    final pink = AppPalette.of(AppThemeChoice.pink);
    expect(AppTabsStyle.card.dotColor, pink.c500);
    expect(AppTabsStyle.solid.pillColor, pink.c500);
    expect(AppTabsStyle.pill.pillColor, pink.c500);
    expect(AppTabsStyle.pill.selectedColor, pink.onAccent);
  });

  testWidgets('Picking an accent and a mode applies and saves them', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = AppRoutes.createRouter(
      initialLocation: AppRoutes.themeSettings,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    // The accent cards are a list; Ягаан is below the fold on a phone.
    await tester.scrollUntilVisible(find.bySemanticsLabel('Ягаан'), 200);
    await tester.tap(find.bySemanticsLabel('Ягаан'));
    await tester.pumpAndSettle();
    expect(appThemeChoice.value, AppThemeChoice.pink);
    expect(await const FlutterSecureStorage().read(key: 'app_theme'), 'pink');

    // The mode tiles scrolled off the top; go back to the top so the tile is
    // fully clear of the header before tapping it.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Харанхуй'));
    await tester.pumpAndSettle();
    expect(appBrightness.value, AppBrightness.dark);
    expect(AppColors.isDark, isTrue);
    expect(
      await const FlutterSecureStorage().read(key: 'app_brightness'),
      'dark',
    );
  });

  test('The saved choices are restored on launch', () async {
    FlutterSecureStorage.setMockInitialValues({
      'app_theme': 'indigo',
      'app_brightness': 'dark',
    });
    await ThemeStore.load();
    expect(appThemeChoice.value, AppThemeChoice.indigo);
    expect(appBrightness.value, AppBrightness.dark);
  });

  test('Unknown saved values keep the defaults', () async {
    appBrightness.value = AppBrightness.system;
    FlutterSecureStorage.setMockInitialValues({
      'app_theme': 'teal',
      'app_brightness': 'dim',
    });
    await ThemeStore.load();
    expect(appThemeChoice.value, AppThemeChoice.sky);
    expect(appBrightness.value, AppBrightness.system);
  });

  testWidgets('Switching mode recolors screens that are already open', (
    tester,
  ) async {
    await tester.pumpWidget(const ArdKidsApp());
    await tester.pumpAndSettle();
    final lightCanvas = AppColors.surface;
    expect(_colors(tester), contains(AppPalette.of(AppThemeChoice.sky).c500));

    appBrightness.value = AppBrightness.dark;
    appThemeChoice.value = AppThemeChoice.pink;
    await tester.pumpAndSettle();

    final colors = _colors(tester);
    final pinkDark = AppPalette.of(AppThemeChoice.pink, dark: true).c500;
    expect(colors, contains(pinkDark));
    expect(colors, isNot(contains(AppPalette.of(AppThemeChoice.sky).c500)));
    expect(AppColors.surface, isNot(lightCanvas));
  });
}
