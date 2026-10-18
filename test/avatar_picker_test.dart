import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'package:new_ard_kids/app/age_group.dart';
import 'package:new_ard_kids/app/avatar.dart';
import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/main.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/common.dart';
import 'package:new_ard_kids/widgets/ui.dart';

Widget _wrap({bool disableAnimations = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: disableAnimations),
  child: MaterialApp.router(
    theme: buildAppTheme(),
    routerConfig: AppRoutes.createRouter(
      initialLocation: AppRoutes.avatarPicker,
    ),
  ),
);

void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 900 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Opacity the entrance is currently applying to [of] (its nearest [Opacity]).
double _entranceOpacity(WidgetTester tester, Finder of) {
  final opacity =
      find
              .ancestor(of: of, matching: find.byType(Opacity))
              .evaluate()
              .first
              .widget
          as Opacity;
  return opacity.opacity;
}

Finder get _title => find.text('Аватараа сонго');

/// The pop applied to the card showing [name]'s mascot.
double _mascotScale(WidgetTester tester, String name) {
  final scale = tester
      .widgetList<ScaleTransition>(
        find.ancestor(
          of: find.byWidgetPredicate(
            (w) => w is MascotImage && w.semanticLabel == name,
          ),
          matching: find.byType(ScaleTransition),
        ),
      )
      .first;
  return scale.scale.value;
}

/// Whether an [Image] showing [asset] is on screen.
bool _showsAsset(WidgetTester tester, String asset) => tester
    .widgetList<Image>(find.byType(Image))
    .any(
      (i) =>
          i.image is AssetImage && (i.image as AssetImage).assetName == asset,
    );

void main() {
  // appAvatar is global and outlives a test.
  // appAgeGroup too; 10–13 is the default and shows the streetwear set.
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    appAvatar.value = AppAvatar.fox;
    appAgeGroup.value = AgeGroup.tween;
  });
  tearDown(() {
    appAvatar.value = AppAvatar.fox;
    appAgeGroup.value = AgeGroup.tween;
    // Confirming an avatar also sets its accent.
    appThemeChoice.value = AppThemeChoice.sky;
  });

  testWidgets('Avatar: the picker offers the set for the age range', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    for (final (age, names) in [
      (AgeGroup.under10, ['Гангаа', 'Цахиа', 'Хөөсөө', 'Вайбаа']),
      (AgeGroup.tween, ['Гангаа', 'Цахиа', 'Хөөсөө', 'Вайбаа']),
      (AgeGroup.teen, ['Гангаа', 'Цахиа', 'Хөөсөө', 'Вайбаа']),
    ]) {
      appAgeGroup.value = age;
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(milliseconds: 900));
      for (final name in names) {
        expect(find.text(name), findsOneWidget, reason: '$age $name');
      }
      // Every age shows the bean characters on the cards.
      for (final avatar in AppAvatar.forAge(age)) {
        expect(
          _showsAsset(tester, avatar.portrait),
          isTrue,
          reason: '$age $avatar',
        );
      }
    }
  });

  testWidgets('Avatar: content fades in and settles fully opaque', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(_wrap());

    expect(_entranceOpacity(tester, _title), 0);

    // The whole entrance is 850ms.
    await tester.pump(const Duration(milliseconds: 900));
    expect(_entranceOpacity(tester, _title), 1);
  });

  testWidgets('Avatar: reduced motion shows the finished layout immediately', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(_wrap(disableAnimations: true));

    expect(_entranceOpacity(tester, _title), 1);
  });

  testWidgets('Avatar: picking a new avatar pops its portrait and ticks it', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(_wrap());
    await tester.pump(const Duration(milliseconds: 900));

    // The first card is selected by default, so pick a different one.
    expect(_mascotScale(tester, 'Цахиа'), 1);

    await tester.tap(find.text('Цахиа'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    // Mid-pop the mascot is larger than its resting size.
    expect(_mascotScale(tester, 'Цахиа'), greaterThan(1));

    await tester.pump(const Duration(milliseconds: 600));
    expect(_mascotScale(tester, 'Цахиа'), 1);

    // Exactly one avatar carries the tick.
    expect(
      find.byWidgetPredicate(
        (w) => w is LineIcon && w.glyph == LineGlyph.check,
      ),
      findsOneWidget,
    );
  });

  testWidgets('Avatar: saving a companion swaps the Home and Profile images', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    final router = AppRoutes.createRouter(initialLocation: AppRoutes.home);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();
    // Home shows the companion in its header.
    expect(_showsAsset(tester, AppAvatar.fox.portrait), isTrue);

    router.push(AppRoutes.avatarPickerEdit);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.text('Цахиа'));
    await tester.pump();
    final save = find.text('Аватараа хадгалах');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(appAvatar.value, AppAvatar.bear);
    expect(await const FlutterSecureStorage().read(key: 'app_avatar'), 'bear');
    // The bear brings Цэнхэр with it.
    expect(appThemeChoice.value, AppThemeChoice.blue);
    expect(await const FlutterSecureStorage().read(key: 'app_theme'), 'blue');
    expect(_showsAsset(tester, AppAvatar.bear.portrait), isTrue);
    expect(_showsAsset(tester, AppAvatar.fox.portrait), isFalse);
  });

  testWidgets('Avatar: the Home header follows the chosen companion', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(const ArdKidsApp());
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go(AppRoutes.home);
    await tester.pumpAndSettle();
    expect(_showsAsset(tester, AppAvatar.fox.portrait), isTrue);

    // Already-open screens follow the change, not only newly opened ones.
    for (final (previous, next) in [
      (AppAvatar.fox, AppAvatar.bear),
      (AppAvatar.bear, AppAvatar.bunny),
      (AppAvatar.bunny, AppAvatar.penguin),
    ]) {
      appAvatar.value = next;
      await tester.pumpAndSettle();
      expect(_showsAsset(tester, next.portrait), isTrue);
      expect(_showsAsset(tester, previous.portrait), isFalse);
    }
  });

  testWidgets('Avatar: summary cards carry the bean avatar, not 14+', (
    tester,
  ) async {
    // The asset names on screen, unwrapping resized images.
    List<String> assets() => [
      for (final i in tester.widgetList<Image>(find.byType(Image)))
        switch (i.image) {
          ResizeImage(imageProvider: AssetImage(:final assetName)) => assetName,
          AssetImage(:final assetName) => assetName,
          _ => '',
        },
    ];
    final oldCompanion = RegExp(r'/(fox|bear|rabbit|penguin|cat)/');

    _usePhoneViewport(tester);
    await tester.pumpWidget(const ArdKidsApp());
    await tester.pumpAndSettle();
    // 10–13: the fox's bean stands on the card, with none of the old art.
    for (final route in [AppRoutes.savingsDeposit, AppRoutes.savingsAccount]) {
      GoRouter.of(tester.element(find.byType(Scaffold).first)).go(route);
      await tester.pumpAndSettle();
      expect(assets(), contains(AppAvatar.fox.portrait), reason: route);
      expect(assets().where(oldCompanion.hasMatch), isEmpty, reason: route);
    }

    // Under 10 too.
    appAgeGroup.value = AgeGroup.under10;
    appAvatar.value = AppAvatar.bunny;
    await tester.pumpAndSettle();
    expect(assets(), contains(AppAvatar.bunny.portrait));
    expect(assets().where(oldCompanion.hasMatch), isEmpty);

    // 14+ keeps the plain card.
    appAgeGroup.value = AgeGroup.teen;
    await tester.pumpAndSettle();
    expect(assets(), isNot(contains(AppAvatar.bunny.portrait)));
  });
}
