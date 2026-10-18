import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/transfer/data/transfer_receipt.dart';
import 'package:new_ard_kids/theme/app_theme.dart';

const _message = 'Танд 100 ардын эрх орлоо!';

Future<void> _pump(WidgetTester tester, {TransferReceipt? receipt}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final router = AppRoutes.createRouter(
    initialLocation: AppRoutes.transferSuccess,
    extra: receipt,
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
  );
  // The receipt rises in, then the avatar follows.
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  testWidgets('Transfer reward: the avatar says what the transfer earned', (
    tester,
  ) async {
    await _pump(
      tester,
      receipt: TransferReceipt(
        amount: 15000,
        recipient: 'Анар (Дүү)',
        bank: 'Хаан банк',
        destination: '5049 8219 02',
        note: 'Хоол',
        balanceAfter: 552930,
        time: DateTime(2026, 10, 19, 14, 32),
      ),
    );
    expect(find.text(_message), findsOneWidget);
    // At the top, not in the middle.
    expect(tester.getCenter(find.text(_message)).dy, lessThan(844 / 4));

    // It goes by itself after a moment.
    await tester.pump(const Duration(seconds: 3));
    expect(find.text(_message), findsOneWidget);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.text(_message), findsNothing);
    expect(find.text('Гүйлгээ амжилттай'), findsOneWidget);
  });

  testWidgets('Transfer reward: none without a real transfer', (tester) async {
    await _pump(tester);
    expect(find.text(_message), findsNothing);
  });
}
