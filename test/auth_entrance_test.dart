import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/theme/app_theme.dart';

Widget _wrap({
  bool disableAnimations = false,
  String location = AppRoutes.auth,
  Object? extra,
}) => MediaQuery(
  data: MediaQueryData(disableAnimations: disableAnimations),
  child: MaterialApp.router(
    theme: buildAppTheme(),
    routerConfig: AppRoutes.createRouter(
      initialLocation: location,
      extra: extra,
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

Finder get _title => find.text('Ard KIDS');

void main() {
  testWidgets('Auth: content is hidden at the start of the entrance', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap());

    expect(_entranceOpacity(tester, _title), 0);
  });

  testWidgets('Auth: entrance fades the content in and settles fully opaque', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap());

    // Partway through, the title is on its way in but not yet arrived.
    await tester.pump(const Duration(milliseconds: 450));
    final mid = _entranceOpacity(tester, _title);
    expect(mid, greaterThan(0));
    expect(mid, lessThan(1));

    // The whole entrance is 900ms.
    await tester.pump(const Duration(milliseconds: 600));
    expect(_entranceOpacity(tester, _title), 1);
  });

  testWidgets('Auth: reduced motion shows the finished layout immediately', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(disableAnimations: true));

    expect(_entranceOpacity(tester, _title), 1);
  });

  group('OTP', () {
    Finder otpTitle() => find.text('Код баталгаажуулах');

    testWidgets('content fades in and settles fully opaque', (tester) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(
        _wrap(location: AppRoutes.otp, extra: '99112345'),
      );

      expect(_entranceOpacity(tester, otpTitle()), 0);

      // The whole entrance is 750ms.
      await tester.pump(const Duration(milliseconds: 800));
      expect(_entranceOpacity(tester, otpTitle()), 1);
    });

    testWidgets('reduced motion shows the finished layout immediately', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(
        _wrap(
          location: AppRoutes.otp,
          extra: '99112345',
          disableAnimations: true,
        ),
      );

      expect(_entranceOpacity(tester, otpTitle()), 1);
    });

    testWidgets('a pressed digit scales into its box', (tester) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(
        _wrap(location: AppRoutes.otp, extra: '99112345'),
      );
      await tester.pump(const Duration(milliseconds: 800));

      await tester.tap(find.text('7').last);
      await tester.pump();
      // One frame in, the digit exists but has not reached full size.
      await tester.pump(const Duration(milliseconds: 60));

      final scale = tester
          .widgetList<ScaleTransition>(
            find.ancestor(
              of: find.text('7').first,
              matching: find.byType(ScaleTransition),
            ),
          )
          .first;
      expect(scale.scale.value, lessThan(1));

      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('7').first, findsOneWidget);
    });
  });
}
