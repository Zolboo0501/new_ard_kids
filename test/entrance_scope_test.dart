import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_ard_kids/widgets/entrance.dart';

double _opacity(WidgetTester tester, String text) => tester
    .widget<Opacity>(
      find.ancestor(of: find.text(text), matching: find.byType(Opacity)).first,
    )
    .opacity;

Widget _app(List<Widget> children, {bool reduceMotion = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: EntranceScope(
      child: ListView(children: EntranceItem.list(children)),
    ),
  ),
);

void main() {
  testWidgets('items fade in staggered, then settle fully shown', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const [Text('first'), Text('second')]));
    expect(_opacity(tester, 'first'), 0);

    await tester.pump(const Duration(milliseconds: 150));
    // The first item starts before the second one.
    expect(_opacity(tester, 'first'), greaterThan(_opacity(tester, 'second')));

    await tester.pumpAndSettle();
    expect(_opacity(tester, 'first'), 1);
    expect(_opacity(tester, 'second'), 1);
  });

  testWidgets('spacers are left unwrapped', (tester) async {
    final items = EntranceItem.list(const [
      Text('a'),
      SizedBox(height: 8),
      Text('b'),
    ]);
    expect(items[0], isA<EntranceItem>());
    expect(items[1], isA<SizedBox>());
    expect((items[2] as EntranceItem).index, 1);
  });

  testWidgets('reduced motion shows everything immediately', (tester) async {
    await tester.pumpWidget(_app(const [Text('first')], reduceMotion: true));
    expect(
      find.ancestor(of: find.text('first'), matching: find.byType(Opacity)),
      findsNothing,
    );
  });

  testWidgets('without a scope the item is just its child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: EntranceItem(index: 0, child: Text('plain'))),
    );
    expect(
      find.ancestor(of: find.text('plain'), matching: find.byType(Opacity)),
      findsNothing,
    );
  });

  group('ListItemEntrance', () {
    Widget list(int filter, List<String> rows) => MaterialApp(
      home: EntranceScope(
        child: ListView(
          children: [
            for (final (i, r) in rows.indexed)
              ListItemEntrance(id: r, index: i, group: filter, child: Text(r)),
          ],
        ),
      ),
    );

    bool animating(WidgetTester tester, String text) => find
        .ancestor(of: find.text(text), matching: find.byType(Opacity))
        .evaluate()
        .isNotEmpty;

    testWidgets('rows on screen open leave it to the screen entrance', (
      tester,
    ) async {
      await tester.pumpWidget(list(0, ['a', 'b']));
      expect(animating(tester, 'a'), isFalse);
    });

    testWidgets('a filter change cascades the new rows in', (tester) async {
      await tester.pumpWidget(list(0, ['a', 'b']));
      await tester.pumpAndSettle();

      await tester.pumpWidget(list(1, ['c', 'd']));
      await tester.pump(const Duration(milliseconds: 60));
      expect(_opacity(tester, 'c'), greaterThan(_opacity(tester, 'd')));

      await tester.pumpAndSettle();
      expect(_opacity(tester, 'c'), 1);
      expect(_opacity(tester, 'd'), 1);
    });

    testWidgets('a row rebuilt with the same id and filter does not replay', (
      tester,
    ) async {
      await tester.pumpWidget(list(0, ['a']));
      await tester.pumpAndSettle();
      // Same id + group, e.g. scrolled out and back: remounted, not replayed.
      await tester.pumpWidget(list(0, []));
      await tester.pumpWidget(list(0, ['a']));
      expect(animating(tester, 'a'), isFalse);
    });

    testWidgets('always replays a row each time it is rebuilt', (tester) async {
      Widget app(bool shown) => MaterialApp(
        home: EntranceScope(
          child: ListView(
            children: [
              if (shown)
                ListItemEntrance(
                  id: 'card',
                  index: 0,
                  always: true,
                  child: const Text('card'),
                ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(app(true));
      await tester.pumpAndSettle();
      // Like switching away from a tab and back.
      await tester.pumpWidget(app(false));
      await tester.pumpWidget(app(true));
      expect(_opacity(tester, 'card'), lessThan(1));
      await tester.pumpAndSettle();
      expect(_opacity(tester, 'card'), 1);
    });

    testWidgets('delay holds the row back before its cascade starts', (
      tester,
    ) async {
      Widget app(bool shown) => MaterialApp(
        home: EntranceScope(
          child: ListView(
            children: [
              if (shown)
                ListItemEntrance(
                  id: 'row',
                  index: 0,
                  always: true,
                  delay: const Duration(milliseconds: 112),
                  child: const Text('row'),
                ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(app(true));
      await tester.pumpAndSettle();
      await tester.pumpWidget(app(false));
      await tester.pumpWidget(app(true));

      await tester.pump(const Duration(milliseconds: 100));
      expect(_opacity(tester, 'row'), 0);
      await tester.pump(const Duration(milliseconds: 80));
      expect(_opacity(tester, 'row'), greaterThan(0));
      await tester.pumpAndSettle();
      expect(_opacity(tester, 'row'), 1);
    });
  });
}
