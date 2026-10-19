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

  testWidgets('AppTabs: the pill follows a drag and settles on release', (
    tester,
  ) async {
    const tabs = [AppTab('Данс'), AppTab('Нэхэмжлэх'), AppTab('Карт')];
    final changes = <int>[];
    await _pump(tester, tabs: tabs, index: 0, onChanged: changes.add);
    final segment = tester.getSize(find.byType(Row).first).width / 3;

    // Half a segment to the right: the pill sits halfway to Нэхэмжлэх
    // (a quarter of the -1..1 axis) while the finger is down.
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Данс')),
    );
    await gesture.moveBy(const Offset(20, 0)); // past the drag slop
    await gesture.moveBy(Offset(segment / 2, 0));
    await tester.pump();
    expect(_pillX(tester), closeTo(-0.5, 0.1));

    // Back short of halfway and let go slowly: it settles on Данс.
    await gesture.moveBy(Offset(-segment / 4, 0));
    await tester.pump(const Duration(seconds: 1));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(_pillX(tester), -1);

    // Past halfway: Нэхэмжлэх.
    await tester.timedDrag(
      find.text('Данс'),
      Offset(segment * 0.8, 0),
      const Duration(seconds: 2),
    );
    await tester.pump();
    expect(changes, [1]);

    // A quick flick moves one tab its way: from Нэхэмжлэх back to Данс.
    await _pump(tester, tabs: tabs, index: 1, onChanged: changes.add);
    await tester.pumpAndSettle();
    await tester.fling(find.text('Нэхэмжлэх'), const Offset(-100, 0), 1000);
    await tester.pump();
    expect(changes, [1, 0]);
  });

  testWidgets('AppTabSwipe: swiping the content moves the tabs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    var tab = 0;
    double? drag;
    var pastStart = 0, pastEnd = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                AppTabs(
                  tabs: const [AppTab('Урамшуулал'), AppTab('Койн')],
                  index: tab,
                  dragPosition: drag,
                  onChanged: (i) => setState(() => tab = i),
                ),
                Expanded(
                  child: AppTabSwipe(
                    index: tab,
                    count: 2,
                    onChanged: (i) => setState(() => tab = i),
                    onDrag: (p) => setState(() => drag = p),
                    onPastStart: () => pastStart++,
                    onPastEnd: () => pastEnd++,
                    child: const ColoredBox(
                      color: Color(0xFFEEEEEE),
                      child: SizedBox.expand(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final content = find.byType(ColoredBox).last;

    // 85pt to the left, under half a tab (a tab is half the 390pt width):
    // the pill moves that far towards Койн while the finger is down.
    final gesture = await tester.startGesture(tester.getCenter(content));
    await gesture.moveBy(const Offset(-20, 0)); // past the drag slop
    await gesture.moveBy(const Offset(-65, 0));
    await tester.pump();
    expect(_pillX(tester), closeTo(-1 + 2 * 85 / 195, 0.05));
    await tester.pump(const Duration(seconds: 1));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tab, 0);
    expect(_pillX(tester), -1);

    await tester.fling(content, const Offset(-150, 0), 1000);
    await tester.pumpAndSettle();
    expect(tab, 1);
    expect(_pillX(tester), 1);

    // Past either end, the callbacks take over.
    await tester.fling(content, const Offset(-150, 0), 1000);
    await tester.pumpAndSettle();
    expect((tab, pastEnd), (1, 1));

    await tester.fling(content, const Offset(150, 0), 1000);
    await tester.pumpAndSettle();
    await tester.fling(content, const Offset(150, 0), 1000);
    await tester.pumpAndSettle();
    expect((tab, pastStart), (0, 1));
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

    testWidgets('pill keeps the sign-in look: accent pill, round track', (
      tester,
    ) async {
      await pumpStyled(tester, AppTabsStyle.pill);
      final (track, pill) = chrome(tester);

      expect((track.borderRadius! as BorderRadius).topLeft.x, 999);
      // Surfaces carry no outline any more.
      expect(track.border, isNull);
      expect(pill.color, AppColors.sky500);
      expect((pill.borderRadius! as BorderRadius).topLeft.x, 999);
    });

    testWidgets('card keeps the home look: raised pill in a quiet track', (
      tester,
    ) async {
      appBrightness.value = AppBrightness.light;
      addTearDown(() => appBrightness.value = AppBrightness.system);
      await pumpStyled(tester, AppTabsStyle.card);
      final (track, pill) = chrome(tester);

      expect((track.borderRadius! as BorderRadius).topLeft.x, 16);
      expect(track.color, AppColors.slate100);
      expect(pill.color, AppColors.card);
      expect((pill.borderRadius! as BorderRadius).topLeft.x, 12);
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
