import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

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
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    appAvatar.value = AppAvatar.fox;
  });
  tearDown(() => appAvatar.value = AppAvatar.fox);

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
    expect(_mascotScale(tester, 'Бамбарууш'), 1);

    await tester.tap(find.text('Бамбарууш'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    // Mid-pop the mascot is larger than its resting size.
    expect(_mascotScale(tester, 'Бамбарууш'), greaterThan(1));

    await tester.pump(const Duration(milliseconds: 600));
    expect(_mascotScale(tester, 'Бамбарууш'), 1);

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
    await tester.tap(find.text('Бамбарууш'));
    await tester.pump();
    final save = find.text('Аватараа хадгалах');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(appAvatar.value, AppAvatar.bear);
    expect(await const FlutterSecureStorage().read(key: 'app_avatar'), 'bear');
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

  testWidgets('Avatar: task screens show no companion art', (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(const ArdKidsApp());
    await tester.pumpAndSettle();
    for (final route in [AppRoutes.transfer, AppRoutes.savingsAccount]) {
      GoRouter.of(tester.element(find.byType(Scaffold).first)).go(route);
      await tester.pumpAndSettle();
      final companionArt = tester
          .widgetList<Image>(find.byType(Image))
          .map((i) => i.image)
          .whereType<AssetImage>()
          .where(
            (a) => RegExp(r'/(fox|bear|rabbit|penguin)/').hasMatch(a.assetName),
          );
      expect(companionArt, isEmpty, reason: route);
    }
  });
}
