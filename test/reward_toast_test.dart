import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/ui.dart';

const _reward = 'Танд 100 ардын эрх орлоо!';

/// Opens [location] on top of the savings account, so screens that pop on
/// success have somewhere to go back to.
Future<GoRouter> _pump(WidgetTester tester, String location) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final router = AppRoutes.createRouter(
    initialLocation: AppRoutes.savingsAccount,
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
  );
  await tester.pumpAndSettle();
  router.push(location);
  await tester.pumpAndSettle();
  return router;
}

/// Scrolls the screen's list until [text] is built and on screen.
Future<void> _scrollTo(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    200,
    // The page's own list, not a sideways row of chips inside it.
    scrollable: find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .first,
  );
}

/// The toast shows what happened and the reward, then goes by itself.
Future<void> _expectRewardToast(WidgetTester tester, String lead) async {
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.text('$lead $_reward'), findsOneWidget);
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
  expect(find.textContaining(_reward), findsNothing);
}

void main() {
  testWidgets('Reward: a savings deposit earns it', (tester) async {
    await _pump(tester, AppRoutes.savingsDeposit);
    await tester.tap(find.text('₮10k'));
    await tester.pump();
    // The button, not the screen's title.
    await tester.tap(find.widgetWithText(PrimaryButton, 'Орлого хийх'));
    await _expectRewardToast(tester, '₮10,000 хадгаламжид орлоо.');
  });

  testWidgets('Reward: a new goal earns it', (tester) async {
    await _pump(tester, AppRoutes.newGoal);
    await _scrollTo(tester, 'Зорилго үүсгэх');
    await tester.tap(find.text('Зорилго үүсгэх'));
    await _expectRewardToast(tester, '"PlayStation 5 Pro" зорилго үүслээ.');
  });

  testWidgets('Reward: sharing an invite earns it, copying does not', (
    tester,
  ) async {
    await _pump(tester, AppRoutes.inviteFriends);
    await tester.tap(find.text('Хуулах'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining(_reward), findsNothing);

    await _scrollTo(tester, 'Урилга хуваалцах');
    await tester.tap(find.text('Урилга хуваалцах'));
    await _expectRewardToast(tester, 'Урилгын код хуулагдлаа.');
  });
}
