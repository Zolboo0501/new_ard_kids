import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_ard_kids/widgets/ui.dart';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController(text: '15,000'));
  tearDown(() => controller.dispose());

  Future<void> pumpField(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AppTextField(
                controller: controller,
                suffix: GestureDetector(
                  onTap: controller.clear,
                  child: const Icon(Icons.close, key: Key('clear')),
                ),
              ),
              const SizedBox(height: 200),
              const Text('outside'),
            ],
          ),
        ),
      ),
    ),
  );

  /// Whether the (test) on-screen keyboard is showing.
  bool focused(WidgetTester tester) => tester.testTextInput.isVisible;

  testWidgets('tapping outside a field hides the keyboard', (tester) async {
    await pumpField(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focused(tester), isTrue);

    await tester.tap(find.text('outside'));
    await tester.pump();
    expect(focused(tester), isFalse);
  });

  testWidgets('tapping the field\'s own suffix keeps the keyboard', (
    tester,
  ) async {
    await pumpField(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();

    await tester.tap(find.byKey(const Key('clear')));
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(focused(tester), isTrue);
  });
}
