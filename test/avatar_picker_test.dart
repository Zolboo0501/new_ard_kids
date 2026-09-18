import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/common.dart';

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

Finder get _title => find.text('Найзаа сонгоорой! 🐾');

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

void main() {
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

  testWidgets('Avatar: picking a new companion pops its mascot and ticks it', (
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

    // Exactly one card carries the tick.
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });
}
