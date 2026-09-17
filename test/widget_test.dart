import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/main.dart';

void main() {
  testWidgets('Auth screen switches between login and register', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ArdKidsApp());

    expect(find.text('Ard KIDS-д тавтай морил!'), findsOneWidget);
    expect(find.text('Үргэлжлүүлэх 🚀'), findsOneWidget);

    await tester.tap(find.text('Бүртгүүлэх'));
    await tester.pumpAndSettle();

    expect(find.text('Код авах ✨'), findsOneWidget);
  });

  testWidgets('Phone field accepts digits only, max 8', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ArdKidsApp());

    final phone = find.byType(TextField).last;
    await tester.enterText(phone, '99ab1123456');
    await tester.pump();

    expect(tester.widget<TextField>(phone).controller!.text, '99112345');
  });
}
