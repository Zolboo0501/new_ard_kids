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
      _ => null,
    },
};

void main() {
  setUp(() {
    appThemeChoice.value = AppThemeChoice.blue;
    FlutterSecureStorage.setMockInitialValues({});
  });
  tearDown(() => appThemeChoice.value = AppThemeChoice.blue);

  testWidgets('Blue theme keeps the original sky colors', (tester) async {
    expect(AppColors.sky500, const Color(0xFF0EA5E9));
    expect(AppColors.sky600, const Color(0xFF0284C7));
    expect(AppColors.dsPrimary, const Color(0xFF006591));
    expect(AppColors.pageBackground, const Color(0xFFF5F8FE));
    expect(AppColors.pageBackgroundMuted, const Color(0xFFF4F6FB));
  });

  test('Tab styles follow the theme', () {
    expect(AppTabsStyle.card.selectedColor, AppPalette.blue.c600);
    appThemeChoice.value = AppThemeChoice.pink;
    expect(AppTabsStyle.card.selectedColor, AppPalette.pink.c600);
    expect(AppTabsStyle.card.dotColor, AppPalette.pink.c500);
    expect(AppTabsStyle.solid.pillColor, AppPalette.pink.c500);
    expect(
      AppTabsStyle.pill.pillGradient?.colors,
      contains(AppPalette.pink.c500),
    );
  });

  testWidgets('Saving the pink theme applies it', (tester) async {
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

    await tester.tap(find.text('Сарнайн ягаан (Pastel Bloom)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сонгосон өнгийг хадгалах'));
    await tester.pumpAndSettle();

    expect(appThemeChoice.value, AppThemeChoice.pink);
    expect(AppColors.sky500, AppPalette.pink.c500);
    expect(await const FlutterSecureStorage().read(key: 'app_theme'), 'pink');
  });

  test('The saved theme is restored on launch', () async {
    FlutterSecureStorage.setMockInitialValues({'app_theme': 'pink'});
    await ThemeStore.load();
    expect(appThemeChoice.value, AppThemeChoice.pink);
  });

  test('An unknown saved value keeps the blue theme', () async {
    FlutterSecureStorage.setMockInitialValues({'app_theme': 'green'});
    await ThemeStore.load();
    expect(appThemeChoice.value, AppThemeChoice.blue);
  });

  testWidgets('Switching theme recolors screens that are already open', (
    tester,
  ) async {
    await tester.pumpWidget(const ArdKidsApp());
    await tester.pumpAndSettle();
    expect(_colors(tester), contains(AppPalette.blue.c500));

    appThemeChoice.value = AppThemeChoice.pink;
    await tester.pumpAndSettle();

    final colors = _colors(tester);
    expect(colors, contains(AppPalette.pink.c500));
    expect(colors, isNot(contains(AppPalette.blue.c500)));
  });
}
