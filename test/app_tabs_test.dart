import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/app_tabs.dart';

/// Where the sliding pill currently sits on the -1..1 axis.
double _pillX(WidgetTester tester) {
  final align = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
  return (align.alignment as Alignment).x;
}

Future<void> _pump(
  WidgetTester tester, {
  required List<AppTab> tabs,
  required int index,
  required ValueChanged<int> onChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(
        body: Center(
          child: AppTabs(tabs: tabs, index: index, onChanged: onChanged),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('AppTabs: the pill sits over the selected tab', (tester) async {
    const tabs = [AppTab('Данс'), AppTab('Нэхэмжлэх'), AppTab('Карт')];

    await _pump(tester, tabs: tabs, index: 0, onChanged: (_) {});
    expect(_pillX(tester), -1);

    await _pump(tester, tabs: tabs, index: 1, onChanged: (_) {});
    await tester.pumpAndSettle();
    expect(_pillX(tester), 0);

    await _pump(tester, tabs: tabs, index: 2, onChanged: (_) {});
    await tester.pumpAndSettle();
    expect(_pillX(tester), 1);
  });

  testWidgets('AppTabs: tapping a tab reports its index', (tester) async {
    final taps = <int>[];
    await _pump(
      tester,
      tabs: const [AppTab('Нэвтрэх'), AppTab('Бүртгүүлэх')],
      index: 0,
      onChanged: taps.add,
    );

    await tester.tap(find.text('Бүртгүүлэх'));
    await tester.pump();
    expect(taps, [1]);

    await tester.tap(find.text('Нэвтрэх'));
    await tester.pump();
    expect(taps, [1, 0]);
  });

  testWidgets('AppTabs: a single tab does not divide by zero', (tester) async {
    await _pump(
      tester,
      tabs: const [AppTab('Бүгд')],
      index: 0,
      onChanged: (_) {},
    );

    expect(_pillX(tester), -1);
    expect(find.text('Бүгд'), findsOneWidget);
  });

  testWidgets('AppTabs: icons render alongside labels', (tester) async {
    await _pump(
      tester,
      tabs: const [
        AppTab('QR унших', icon: Icons.qr_code_scanner_rounded),
        AppTab('Миний QR', icon: Icons.qr_code_2_rounded),
      ],
      index: 0,
      onChanged: (_) {},
    );

    expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_2_rounded), findsOneWidget);
  });

  group('AppTabView', () {
    Future<void> pumpView(WidgetTester tester, int index) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: AppTabView(
              index: index,
              child: SizedBox(
                height: 100.0 + index * 40,
                child: Text('pane $index'),
              ),
            ),
          ),
        ),
      );
    }

    /// Highest opacity any pane is showing right now.
    double brightest(WidgetTester tester) {
      final fades = tester.widgetList<FadeTransition>(
        find.byType(FadeTransition),
      );
      return fades.isEmpty
          ? 1
          : fades.map((f) => f.opacity.value).reduce((a, b) => a > b ? a : b);
    }

    testWidgets('the outgoing pane stays put instead of lurching', (
      tester,
    ) async {
      await pumpView(tester, 0);
      await tester.pumpAndSettle();
      final restingY = tester.getTopLeft(find.text('pane 0')).dy;

      await pumpView(tester, 1);
      // A bare AnimatedSwitcher re-centres the outgoing pane in a stack sized
      // to the taller incoming one, so it visibly drops while fading out.
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 40));
        if (find.text('pane 0').evaluate().isEmpty) break;
        expect(tester.getTopLeft(find.text('pane 0')).dy, restingY);
      }

      await tester.pumpAndSettle();
      expect(find.text('pane 1'), findsOneWidget);
      expect(find.text('pane 0'), findsNothing);
    });

    testWidgets('something stays readable all through the transition', (
      tester,
    ) async {
      await pumpView(tester, 0);
      await tester.pumpAndSettle();

      await pumpView(tester, 1);
      for (var ms = 0; ms <= 320; ms += 20) {
        await tester.pump(const Duration(milliseconds: 20));
        expect(
          brightest(tester),
          greaterThan(0.25),
          reason: 'both panes faded out at ${ms}ms',
        );
      }
    });

    testWidgets('eases between panes of different heights', (tester) async {
      await pumpView(tester, 0);
      await tester.pumpAndSettle();
      final before = tester.getSize(find.byType(AnimatedSize)).height;

      await pumpView(tester, 1);
      await tester.pump(const Duration(milliseconds: 160));
      final mid = tester.getSize(find.byType(AnimatedSize)).height;

      await tester.pumpAndSettle();
      final after = tester.getSize(find.byType(AnimatedSize)).height;

      // 100 -> 140, and partway there at the midpoint rather than snapping.
      expect(before, 100);
      expect(after, 140);
      expect(mid, greaterThan(before));
      expect(mid, lessThan(after));
    });

    testWidgets('reduced motion swaps panes with no transition', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            theme: buildAppTheme(),
            home: const Scaffold(
              body: AppTabView(index: 1, child: Text('pane 1')),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedSwitcher), findsNothing);
      expect(find.text('pane 1'), findsOneWidget);
    });
  });

  group('AppTabsStyle', () {
    /// The track and pill decorations an AppTabs is currently painting.
    (BoxDecoration, BoxDecoration) chrome(WidgetTester tester) {
      final track =
          tester
                  .widget<Container>(
                    find
                        .descendant(
                          of: find.byType(AppTabs),
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      final pill =
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byType(AnimatedAlign),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      return (track, pill);
    }

    Future<void> pumpStyled(WidgetTester tester, AppTabsStyle style) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: Center(
              child: AppTabs(
                tabs: const [AppTab('A'), AppTab('B')],
                index: 0,
                style: style,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('pill keeps the sign-in look: gradient on a round track', (
      tester,
    ) async {
      await pumpStyled(tester, AppTabsStyle.pill);
      final (track, pill) = chrome(tester);

      expect((track.borderRadius! as BorderRadius).topLeft.x, 999);
      expect(track.border, isNotNull);
      expect(pill.gradient, isNotNull);
      expect((pill.borderRadius! as BorderRadius).topLeft.x, 999);
    });

    testWidgets('card keeps the home look: white pill on a sky track', (
      tester,
    ) async {
      await pumpStyled(tester, AppTabsStyle.card);
      final (track, pill) = chrome(tester);

      expect((track.borderRadius! as BorderRadius).topLeft.x, 16);
      expect(pill.color, Colors.white);
      expect((pill.borderRadius! as BorderRadius).topLeft.x, 12);
      expect(pill.boxShadow, isNotNull);
    });

    testWidgets('solid keeps the QR look: sky pill, borderless track', (
      tester,
    ) async {
      await pumpStyled(tester, AppTabsStyle.solid);
      final (track, pill) = chrome(tester);

      expect((track.borderRadius! as BorderRadius).topLeft.x, 16);
      expect(track.border, isNull);
      expect(pill.color, AppColors.sky500);
      expect(pill.boxShadow, isNull);
    });
  });
}
