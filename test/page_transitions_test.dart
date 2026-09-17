import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_ard_kids/app/page_transitions.dart';

/// Minimal router with a home page and one pushed page using [transition].
GoRouter _router(AppTransition transition) => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, _) => Scaffold(
        body: TextButton(
          onPressed: () => context.push('/next'),
          child: const Text('open'),
        ),
      ),
    ),
    GoRoute(
      path: '/next',
      pageBuilder: (_, state) => buildTransitionPage(
        state: state,
        transition: transition,
        child: const Scaffold(body: Text('next page')),
      ),
    ),
  ],
);

double _nextPageLeft(WidgetTester tester) =>
    tester.getTopLeft(find.text('next page')).dx;

void main() {
  testWidgets('slide transition moves the page in from the right', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: _router(AppTransition.slide)),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    final midway = _nextPageLeft(tester);
    expect(midway, greaterThan(0));

    await tester.pumpAndSettle();
    expect(_nextPageLeft(tester), lessThan(midway));
    expect(_nextPageLeft(tester), 0);
  });

  testWidgets('reduced motion shows the page immediately', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp.router(routerConfig: _router(AppTransition.slide)),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(_nextPageLeft(tester), 0);
  });
}
