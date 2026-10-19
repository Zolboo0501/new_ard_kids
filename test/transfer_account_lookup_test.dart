import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/features/transfer/data/bank.dart';
import 'package:new_ard_kids/features/transfer/presentation/widgets/account_search_sheet.dart';
import 'package:new_ard_kids/features/transfer/presentation/widgets/bank_picker.dart';
import 'package:new_ard_kids/theme/app_theme.dart';

Future<void> _openSearchSheet(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final router = AppRoutes.createRouter(initialLocation: AppRoutes.transfer);
  await tester.pumpWidget(
    MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
  );
  router.go(AppRoutes.transfer);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Дансаар'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Хайх'));
  await tester.pumpAndSettle();
  expect(find.text('Данс хайх'), findsOneWidget);
}

Finder get _numberField => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.hintText == '10 оронтой дансны дугаар',
);

/// Types [number] into the sheet and taps its Хайх.
Future<void> _search(WidgetTester tester, String number) async {
  await tester.enterText(_numberField, number);
  await tester.pump();
  await tester.tap(find.text('Хайх').last);
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Дансаар: the sheet finds an account by its plain number', (
    tester,
  ) async {
    await _openSearchSheet(tester);

    await _search(tester, '5049821902');
    expect(find.text('5049 8219 02'), findsOneWidget);
    expect(find.text('Б. Сүхбат'), findsOneWidget);
    expect(find.text('MN24 0005 0050 4982 1902'), findsOneWidget);

    await tester.tap(find.text('Сонгох'));
    await tester.pumpAndSettle();
    expect(find.text('Данс хайх'), findsNothing);
    // The picked account fills the IBAN field and shows its holder.
    expect(find.text('MN24 0005 0050 4982 1902'), findsOneWidget);
    expect(find.text('Б. Сүхбат'), findsOneWidget);
  });

  testWidgets('Дансаар: 5752 0289 15 is found', (tester) async {
    await _openSearchSheet(tester);
    await _search(tester, '5752028915');
    expect(find.text('Н. Отгонбаяр'), findsOneWidget);
    expect(find.text('MN21 0005 0057 5202 8915'), findsOneWidget);
  });

  testWidgets('Дансаар: any number is found and can be picked', (tester) async {
    await _openSearchSheet(tester);

    await _search(tester, '1234567890');
    final account = AccountSearchSheet.lookup('1234567890');
    expect(find.text('Данс олдсонгүй. Дугаараа шалгана уу.'), findsNothing);
    expect(find.text(account.holder), findsOneWidget);
    expect(find.text(account.iban), findsOneWidget);

    await tester.tap(find.text('Сонгох'));
    await tester.pumpAndSettle();
    expect(find.text('Данс хайх'), findsNothing);
    expect(find.text(account.iban), findsOneWidget);
  });

  testWidgets('Дансаар: the bank is picked by its logo', (tester) async {
    await _openSearchSheet(tester);
    expect(find.byType(BankLogo), findsNWidgets(Bank.all.length));

    await tester.tap(find.text('Голомт'));
    await tester.pump();
    // A known Хаан банк number is another account at Голомт.
    await _search(tester, '5049821902');
    final account = AccountSearchSheet.lookup('5049821902', bank: Bank.all[1]);
    expect(find.text('Голомт банк'), findsOneWidget);
    expect(find.text(account.iban), findsOneWidget);
    expect(account.iban, startsWith('MN'));
    expect(account.iban.replaceAll(' ', '').substring(4, 8), '0015');
  });

  test('Дансаар: mock accounts get a valid IBAN', () {
    for (final (number, bank) in [
      for (final n in ['1234567890', '42', '9999999999'])
        for (final b in Bank.all) (n, b),
    ]) {
      final iban = AccountSearchSheet.lookup(
        number,
        bank: bank,
      ).iban.replaceAll(' ', '');
      // ISO 13616: move the first four to the end, letters to numbers.
      final digits = '${iban.substring(4)}2223${iban.substring(2, 4)}';
      var rest = 0;
      for (final c in digits.codeUnits) {
        rest = (rest * 10 + c - 48) % 97;
      }
      expect(rest, 1, reason: iban);
    }
  });
}
