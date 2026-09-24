import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/app_loader.dart';

void main() {
  testWidgets('Shows the loading screen until load finishes, then the app', (
    tester,
  ) async {
    final load = Completer<void>();
    await tester.pumpWidget(
      AppLoader(
        load: () => load.future,
        builder: (_) => const MaterialApp(home: Text('ready')),
      ),
    );

    expect(find.byType(AppLoadingScreen), findsOneWidget);
    expect(find.text('ready'), findsNothing);

    // The spinner fades in only after a short delay.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    load.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('ready'), findsOneWidget);
    expect(find.byType(AppLoadingScreen), findsNothing);
  });

  testWidgets('A failed load still opens the app', (tester) async {
    await tester.pumpWidget(
      AppLoader(
        load: () => Future.error(Exception('storage')),
        builder: (_) => const MaterialApp(home: Text('ready')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('ready'), findsOneWidget);
  });
}
