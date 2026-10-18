import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_ard_kids/app/avatar.dart';
import 'package:new_ard_kids/app/home_tour_store.dart';
import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/theme/app_theme.dart';

Future<void> _pumpHome(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = AppRoutes.createRouter(initialLocation: AppRoutes.home);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
  );
  // The tour waits for the screen to settle in.
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  tearDown(() => HomeTourStore.pending = false);

  testWidgets('Home tour: the avatar walks through Home once', (tester) async {
    HomeTourStore.pending = true;
    await _pumpHome(tester);

    final name = appAvatar.value.name;
    expect(find.textContaining('Би $name'), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Дараах'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Эхэлцгээе'));
    await tester.pumpAndSettle();

    expect(find.text('Дараах'), findsNothing);
    expect(HomeTourStore.pending, isFalse);
    expect(
      await const FlutterSecureStorage().read(key: HomeTourStore.key),
      'true',
    );
  });

  testWidgets('Home tour: Алгасах ends it straight away', (tester) async {
    HomeTourStore.pending = true;
    await _pumpHome(tester);

    await tester.tap(find.text('Алгасах'));
    await tester.pumpAndSettle();

    expect(find.text('Дараах'), findsNothing);
    expect(HomeTourStore.pending, isFalse);
  });

  testWidgets('Home tour: not shown once it was done', (tester) async {
    await _pumpHome(tester);
    expect(find.text('Дараах'), findsNothing);
  });

  test(
    'Home tour: a fresh install owes the tour, a finished one does not',
    () async {
      await HomeTourStore.load();
      expect(HomeTourStore.pending, isTrue);
      await HomeTourStore.complete();
      HomeTourStore.pending = true;
      await HomeTourStore.load();
      expect(HomeTourStore.pending, isFalse);
    },
  );
}
