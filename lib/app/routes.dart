import 'package:go_router/go_router.dart';
import 'package:new_ard_kids/features/auth/presentation/screens/auth_screen.dart';
import 'package:new_ard_kids/features/auth/presentation/screens/friend_code_screen.dart';
import 'package:new_ard_kids/features/auth/presentation/screens/otp_screen.dart';

import '../widgets/ui/line_icons.dart';
import '../features/accounts/presentation/screens/card_screen.dart';
import '../features/accounts/presentation/screens/card_order_screen.dart';

import '../features/accounts/presentation/screens/reward_opportunities_screen.dart';
import '../features/accounts/presentation/screens/rewards_account_screen.dart';
import '../features/accounts/presentation/screens/stocks_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/chat/presentation/screens/chat_thread_screen.dart';
import '../features/chat/presentation/screens/new_chat_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/home_shell.dart';
import '../features/home/presentation/screens/invoice_history_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/onboarding/presentation/screens/age_group_screen.dart';
import '../features/onboarding/presentation/screens/avatar_picker_screen.dart';
import '../features/onboarding/presentation/screens/biometric_setup_screen.dart';
import '../features/onboarding/presentation/screens/parent_link_screen.dart';
import '../features/profile/presentation/screens/edit_personal_info_screen.dart';
import '../features/profile/presentation/screens/personal_info_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/security_screen.dart';
import '../features/profile/presentation/screens/theme_settings_screen.dart';
import '../features/savings/presentation/screens/new_goal_screen.dart';
import '../features/savings/presentation/screens/savings_account_screen.dart';
import '../features/savings/presentation/screens/savings_calculator_screen.dart';
import '../features/savings/presentation/screens/savings_deposit_screen.dart';
import '../features/savings/presentation/screens/savings_history_screen.dart';
import '../features/social/presentation/screens/add_friend_screen.dart';
import '../features/social/presentation/screens/invite_friends_screen.dart';
import '../features/transfer/presentation/screens/qr_scan_screen.dart';
import '../features/transfer/presentation/screens/request_list_screen.dart';
import '../features/transfer/presentation/screens/request_money_screen.dart';
import '../features/transfer/presentation/screens/transfer_amount_screen.dart';
import '../features/transfer/presentation/screens/transfer_screen.dart';
import '../features/transfer/data/transfer_receipt.dart';
import '../features/transfer/presentation/screens/transfer_success_screen.dart';
import '../features/onboarding/presentation/screens/welcome_screen.dart';
import 'page_transitions.dart';

/// Route paths for every screen in the app.
///
/// Navigate with go_router: `context.push(AppRoutes.x)` to stack a screen,
/// `context.go(AppRoutes.x)` to replace the whole stack (e.g. after sign-in),
/// and pass data through `extra` (see [otp] and [transferSuccess]).
abstract final class AppRoutes {
  static const auth = '/';
  static const welcome = '/welcome';
  static const register = '/?mode=register';

  /// `extra`: the 8-digit phone number as a [String].
  static const otp = '/otp';
  static const friendCode = '/friend-code';

  /// Home tab of the signed-in shell. [homeUnlinked] is the same route in
  /// the "Эцэг эх холбогдоогүй" state (`?linked=false`).
  static const home = '/home';
  static const homeUnlinked = '/home?linked=false';

  /// "Насаа сонгох": the first registration step after the phone is
  /// verified.
  static const ageGroup = '/onboarding/age';

  /// The age screen opened from Profile: saves and returns.
  static const ageGroupEdit = '$ageGroup?edit=true';
  static const avatarPicker = '/onboarding/avatar';

  /// The parent link, the last registration step; also opened later from
  /// Home or Profile, where it has no step pill.
  static const parentLink = '/onboarding/parent';

  /// Offers biometric sign-in during registration, between the friend code
  /// and the parent link. Skipped when the device has no biometric sensor.
  static const biometricSetup = '/onboarding/biometric';

  /// Avatar picker opened from Profile: saves and returns instead of
  /// continuing onboarding.
  static const avatarPickerEdit = '$avatarPicker?edit=true';

  /// Parent link as the last registration step: shows the step pill and the
  /// skip button. Opened from Home or Profile ([parentLink]) it has neither.
  static const parentLinkOnboarding = '$parentLink?onboarding=true';

  /// "Гүйлгээний дүн": the keypad step before [transfer], opened from Home.
  static const transferAmount = '/transfer/amount';

  /// `extra`: the amount (an [int]) typed on [transferAmount], if any.
  static const transfer = '/transfer';

  /// `extra`: a [TransferReceipt]; a sample receipt is shown without one.
  static const transferSuccess = '/transfer/success';
  static const qrScan = '/qr';

  /// The keypad step before [requestMoney], opened from Home.
  static const requestAmount = '/request/amount';

  /// `extra`: the amount (an [int]) typed on [requestAmount], if any.
  static const requestMoney = '/request';
  static const requestList = '/request/list';

  /// [requestList] opened on its Хүлээгдэж буй filter, after a request is
  /// sent.
  static const requestListPending = '$requestList?filter=pending';
  static const invoiceHistory = '/invoices/history';

  static const savingsAccount = '/savings';
  static const savingsHistory = '/savings/history';
  static const savingsDeposit = '/savings/deposit';
  static const savingsCalculator = '/savings/calculator';
  static const newGoal = '/savings/goal/new';

  static const coinAccount = '/accounts/coin';
  static const rewardsAccount = '/accounts/rewards';
  static const rewardOpportunities = '/accounts/rewards/opportunities';
  static const stocks = '/accounts/stocks';
  static const card = '/card';
  static const cardOrder = '/card/order';
  // static const cart = '/cart';

  static const addFriend = '/friends/add';
  static const inviteFriends = '/friends/invite';
  static const notifications = '/notifications';

  /// The Чат tab of the signed-in shell.
  static const chat = '/chat';

  /// One conversation, opened from [chat]; `?id=` picks the thread.
  static const chatThread = '/chat/thread';
  static String chatThreadOf(String id) => '$chatThread?id=$id';

  /// "Шинэ чат": find someone by @username and start a conversation.
  static const newChat = '/chat/new';

  static const profile = '/profile';
  static const personalInfo = '/profile/info';
  static const editPersonalInfo = '/profile/info/edit';
  static const security = '/profile/security';
  static const themeSettings = '/profile/theme';

  static final Map<String, GoRouterWidgetBuilder> _builders = {
    welcome: (_, _) => const PlainLineIcons(child: WelcomeScreen()),
    auth: (_, state) => PlainLineIcons(
      child: AuthScreen(
        initialMode: state.uri.queryParameters['mode'] == 'register'
            ? AuthMode.register
            : AuthMode.login,
      ),
    ),
    otp: (_, state) =>
        PlainLineIcons(child: OtpScreen(phone: state.extra as String? ?? '')),
    ageGroup: (_, state) =>
        AgeGroupScreen(editing: state.uri.queryParameters['edit'] == 'true'),
    friendCode: (_, _) => const PlainLineIcons(child: FriendCodeScreen()),
    avatarPicker: (_, state) => AvatarPickerScreen(
      editing: state.uri.queryParameters['edit'] == 'true',
    ),
    biometricSetup: (_, _) => const BiometricSetupScreen(),
    parentLink: (_, state) => ParentLinkScreen(
      onboarding: state.uri.queryParameters['onboarding'] == 'true',
    ),
    transferAmount: (_, _) => const TransferAmountScreen(),
    transfer: (_, state) => TransferScreen(initialAmount: state.extra as int?),
    transferSuccess: (_, state) =>
        TransferSuccessScreen(receipt: state.extra as TransferReceipt?),
    requestAmount: (_, _) => const TransferAmountScreen(request: true),
    requestMoney: (_, state) =>
        RequestMoneyScreen(initialAmount: state.extra as int?),
    requestList: (_, state) => RequestListScreen(
      showPending: state.uri.queryParameters['filter'] == 'pending',
    ),
    invoiceHistory: (_, _) => const InvoiceHistoryScreen(),
    savingsAccount: (_, _) => const SavingsAccountScreen(),
    savingsHistory: (_, _) => const SavingsHistoryScreen(),
    savingsDeposit: (_, _) => const SavingsDepositScreen(),
    savingsCalculator: (_, _) => const SavingsCalculatorScreen(),
    newGoal: (_, _) => const NewGoalScreen(),
    coinAccount: (_, _) => const RewardsAccountScreen(initialTab: 1),
    rewardsAccount: (_, _) => const RewardsAccountScreen(),
    rewardOpportunities: (_, _) => const RewardOpportunitiesScreen(),
    stocks: (_, _) => const StocksScreen(),
    card: (_, _) => const CardScreen(),
    cardOrder: (_, _) => const CardOrderScreen(),
    // cart: (_, _) => const CartScreen(),
    addFriend: (_, _) => const AddFriendScreen(),
    inviteFriends: (_, _) => const InviteFriendsScreen(),
    notifications: (_, _) => const NotificationsScreen(),
    chatThread: (_, state) =>
        ChatThreadScreen(threadId: state.uri.queryParameters['id']),
    newChat: (_, _) => const NewChatScreen(),
    personalInfo: (_, _) => const PersonalInfoScreen(),
    editPersonalInfo: (_, _) => const EditPersonalInfoScreen(),
    security: (_, _) => const SecurityScreen(),
    themeSettings: (_, _) => const ThemeSettingsScreen(),
  };

  /// Routes that don't use the default [AppTransition.slide].
  static const Map<String, AppTransition> _transitions = {
    // Stack resets via `context.go`.
    auth: AppTransition.fade,
    welcome: AppTransition.fade,
    // Task-style screens opened and dismissed as a unit.
    transferSuccess: AppTransition.rise,
  };

  /// Every navigable location, including the shell tabs (used by the smoke
  /// test).
  static Iterable<String> get paths => [
    ..._builders.keys,
    home,
    qrScan,
    homeUnlinked,
    parentLinkOnboarding,
    chat,
    profile,
  ];

  /// Builds the app router. Tests pass [initialLocation] to start on a screen.
  static GoRouter createRouter({String initialLocation = auth, Object? extra}) {
    return GoRouter(
      initialLocation: 'welcome',
      initialExtra: extra,
      routes: [
        // Bottom-nav tabs. Each branch keeps its own navigator and state, so
        // switching tabs restores where the user left off. Screens pushed from
        // a tab are top-level routes and cover the nav bar.
        StatefulShellRoute.indexedStack(
          pageBuilder: (context, state, navigationShell) => buildTransitionPage(
            state: state,
            transition: AppTransition.fade,
            child: HomeShell(navigationShell: navigationShell),
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: home,
                  pageBuilder: (context, state) => NoTransitionPage(
                    child: HomeScreen(
                      parentLinked:
                          state.uri.queryParameters['linked'] != 'false',
                    ),
                  ),
                ),
              ],
            ),
            // QR sits after Home, a tab like the others so the bar stays
            // put under it.
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: qrScan,
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: QrScanScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: chat,
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: ChatScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: profile,
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: ProfileScreen(embedded: true),
                  ),
                ),
              ],
            ),
          ],
        ),
        for (final MapEntry(key: path, value: builder) in _builders.entries)
          GoRoute(
            path: path,
            pageBuilder: (context, state) => buildTransitionPage(
              state: state,
              child: builder(context, state),
              transition: _transitions[path] ?? AppTransition.slide,
            ),
          ),
      ],
    );
  }
}
