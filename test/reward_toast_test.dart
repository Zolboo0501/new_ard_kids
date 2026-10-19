import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_ard_kids/app/avatar.dart';
import 'package:new_ard_kids/app/routes.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/avatar_toast.dart';
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

/// Whether the toast's character is drawn from [path].
Finder _art(String path) => find.descendant(
  of: find.byType(AvatarToast),
  matching: find.byWidgetPredicate(
    (w) =>
        w is Image &&
        w.image is AssetImage &&
        (w.image as AssetImage).assetName == path,
  ),
);

void main() {
  tearDown(() => appAvatar.value = AppAvatar.fox);

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

  testWidgets('Action messages: the avatar says them and a drag up closes it', (
    tester,
  ) async {
    await _pump(tester, AppRoutes.inviteFriends);
    await tester.tap(find.text('Хуулах'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Урилгын код хуулагдлаа'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    // A short, slow drag snaps back and keeps it.
    await tester.timedDrag(
      find.text('Урилгын код хуулагдлаа'),
      const Offset(0, -28),
      const Duration(milliseconds: 600),
    );
    await tester.pumpAndSettle();
    expect(find.text('Урилгын код хуулагдлаа'), findsOneWidget);

    // Dragged up past the threshold, it goes at once.
    await tester.drag(
      find.text('Урилгын код хуулагдлаа'),
      const Offset(0, -80),
    );
    await tester.pumpAndSettle();
    expect(find.text('Урилгын код хуулагдлаа'), findsNothing);
  });

  testWidgets('Action messages: a new one replaces the one showing', (
    tester,
  ) async {
    await _pump(tester, AppRoutes.inviteFriends);
    await tester.tap(find.text('Хуулах'));
    await tester.pump(const Duration(milliseconds: 400));
    await _scrollTo(tester, 'Урилга хуваалцах');
    await tester.tap(find.text('Урилга хуваалцах'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Урилгын код хуулагдлаа'), findsNothing);
    expect(find.textContaining(_reward), findsOneWidget);
  });

  /// Deposits into savings as [avatar] and expects the toast to draw [art].
  Future<void> expectDepositArt(
    WidgetTester tester,
    AppAvatar avatar,
    String art,
  ) async {
    appAvatar.value = avatar;
    await _pump(tester, AppRoutes.savingsDeposit);
    await tester.tap(find.text('₮10k'));
    await tester.pump();
    await tester.tap(find.widgetWithText(PrimaryButton, 'Орлого хийх'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(_art(art), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  testWidgets('Reward: Гангаа greets it in its own pose', (tester) async {
    await expectDepositArt(
      tester,
      AppAvatar.fox,
      'assets/images/avatars/bean/orange/savings.webp',
    );
  });

  testWidgets('Reward: Цахиа greets it in its own pose', (tester) async {
    await expectDepositArt(
      tester,
      AppAvatar.bear,
      'assets/images/avatars/bean/green/savings.webp',
    );
  });

  testWidgets('Reward: Хөөсөө greets it in its own pose', (tester) async {
    await expectDepositArt(
      tester,
      AppAvatar.bunny,
      'assets/images/avatars/bean/pink/savings.webp',
    );
  });

  testWidgets('Reward: Вайбаа greets it in its own pose', (tester) async {
    await expectDepositArt(
      tester,
      AppAvatar.cat,
      'assets/images/avatars/bean/purple/savings.webp',
    );
  });
}
