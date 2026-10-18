import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/accounts.dart';
import '../../../../app/avatar.dart';
import '../../../../app/home_tour_store.dart';
import '../../../../app/kid_profile.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/ui.dart';
import '../../../../widgets/entrance.dart';
import '../../data/card_art.dart';
import '../widgets/accounts_pane.dart';
import '../widgets/balance_card.dart';
import '../widgets/cards_pane.dart';
import '../widgets/home_header.dart';
import '../widgets/invoices_pane.dart';
import '../widgets/locked_accounts_pane.dart';
import '../../data/spending_stats.dart';
import '../widgets/home_spending_card.dart';
import '../widgets/home_tour.dart';
import '../widgets/page_dots.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.parentLinked = true});

  final bool parentLinked;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pages = PageController();
  int _page = 0;
  int _tab = 0;
  int _invoiceFilter = 0;
  bool _hideBalance = false;

  /// What the first-visit tour points at.
  final _balanceKey = GlobalKey();
  final _actionsKey = GlobalKey();
  final _spendingKey = GlobalKey();
  final _tabsKey = GlobalKey();

  /// Every account the balance swipes through: label, number, balance.
  static List<(String, String, int)> get _accounts => [
    ('Харилцах данс', Accounts.main, Balances.main),
    ('Хадгаламж данс', Accounts.savings, Balances.savings),
    ('Миний өв', Accounts.stocks, Balances.stocks),
    ('Урамшууллын данс', Accounts.rewards, Balances.rewards),
    ('Ард койн данс', Accounts.coin, Balances.coins),
  ];

  @override
  void initState() {
    super.initState();
    appAvatar.addListener(_onAvatarChanged);
    // The first visit: the avatar walks the teen through Home as soon as it
    // opens. Its greeting points at nothing, so the screen's entrance
    // finishes behind it before the first spotlight.
    if (HomeTourStore.pending) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startTour());
    }
  }

  Future<void> _startTour() async {
    if (!mounted || !HomeTourStore.pending) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
    // Marked done up front, so it can't open twice.
    unawaited(HomeTourStore.complete());
    final name = appAvatar.value.name;
    await showHomeTour(
      context,
      steps: [
        HomeTourStep(
          text:
              'Сайн уу! Би $name. Ard Kids-ийн нүүр хуудастай хамт '
              'танилцъя!',
        ),
        HomeTourStep(
          target: _balanceKey,
          text:
              'Энд дансны үлдэгдэл чинь харагдана. Хажуу тийш гүйлгээд '
              'бусад дансаа хараарай.',
        ),
        HomeTourStep(
          target: _actionsKey,
          text:
              'Эндээс мөнгө шилжүүлж, эцэг эхээсээ мөнгө хүсэх '
              'боломжтой.',
        ),
        HomeTourStep(
          target: _spendingKey,
          text: 'Энэ 7 хоногт хэдийг юунд зарцуулснаа эндээс хараарай.',
        ),
        HomeTourStep(
          target: _tabsKey,
          text: 'Данс, нэхэмжлэх, картаа эндээс солиод үзээрэй.',
        ),
      ],
    );
  }

  void _onAvatarChanged() => setState(() {});

  @override
  void dispose() {
    appAvatar.removeListener(_onAvatarChanged);
    _pages.dispose();
    super.dispose();
  }

  void _go(String route) => context.push(route);

  /// The selected account's buttons; the first is the accent one.
  List<(String, LineGlyph, VoidCallback)> _actions(
    String account,
  ) => switch (account) {
    Accounts.savings => [
      ('Орлого', LineGlyph.arrowDownLeft, () => _go(AppRoutes.savingsDeposit)),
      (
        'Дэлгэрэнгүй',
        LineGlyph.arrowRight,
        () => _go(AppRoutes.savingsAccount),
      ),
    ],
    Accounts.rewards => [
      ('Найз урих', LineGlyph.personAdd, () => _go(AppRoutes.inviteFriends)),
      (
        'Дэлгэрэнгүй',
        LineGlyph.arrowRight,
        () => _go(AppRoutes.rewardsAccount),
      ),
    ],
    Accounts.stocks => [
      ('Дэлгэрэнгүй', LineGlyph.arrowRight, () => _go(AppRoutes.stocks)),
    ],
    Accounts.coin => [
      ('Дэлгэрэнгүй', LineGlyph.arrowRight, () => _go(AppRoutes.coinAccount)),
    ],
    _ => [
      ('Гүйлгээ', LineGlyph.paperPlane, () => _go(AppRoutes.transferAmount)),
      (
        'Мөнгө хүсэх',
        LineGlyph.arrowDownLeft,
        () => _go(AppRoutes.requestAmount),
      ),
    ],
  };

  /// How far account [i] sits from the one showing, in pages:
  /// 0 when it's showing, ±1 one swipe away. Before the PageView has a size
  /// (first frame) the settled page is used.
  double _pageOffset(int i) {
    final position = _pages.hasClients ? _pages.position : null;
    final page = position != null && position.haveDimensions
        ? _pages.page ?? _page.toDouble()
        : _page.toDouble();
    return i - page;
  }

  @override
  Widget build(BuildContext context) {
    final linked = widget.parentLinked;
    final avatar = appAvatar.value;
    final count = linked ? _accounts.length : 1;
    final current = _accounts[linked ? _page : 0];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppColors.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: AppColors.surface,
        child: Column(
          children: [
            HomeHeader(
              avatar: avatar,
              onNotifications: () => _go(AppRoutes.notifications),
              onSettings: () => _go(AppRoutes.security),
            ),
            Expanded(
              // Split on wide windows: the balance and its actions stay on the left
              // while the accounts, invoices and cards scroll on the right.
              child: EntranceScope(
                child: AdaptiveSplit(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    AppLayout.navClearance(context),
                  ),
                  leading: [
                    // The balance itself is the carousel: swipe it to move
                    // between accounts, with the dots under it.
                    KeyedSubtree(
                      key: _balanceKey,
                      child: _balances(count, linked),
                    ),
                    if (linked) ...[
                      const SizedBox(height: 12),
                      PageDots(count: count, index: _page),
                    ],
                    const SizedBox(height: 20),
                    HomeActions(
                      key: _actionsKey,
                      actions: _actions(linked ? current.$2 : Accounts.main),
                      art: accountActionArt,
                    ),
                    const SizedBox(height: 20),
                    // This week's spending at a glance.
                    HomeSpendingCard(
                      key: _spendingKey,
                      days: weekSpending,
                      dayLabels: weekdayLabels,
                      today: DateTime.now().weekday - 1,
                      lastWeek: lastWeekTotal,
                      categories: weekCategories,
                    ),
                  ],
                  trailing: [
                    AppTabs(
                      key: _tabsKey,
                      tabs: const [
                        AppTab('Данс'),
                        AppTab('Нэхэмжлэх'),
                        AppTab('Карт'),
                      ],
                      index: _tab,
                      dotOnActive: true,
                      style: AppTabsStyle.night,
                      onChanged: (i) => setState(() => _tab = i),
                    ),
                    const SizedBox(height: 14),
                    AppTabView(
                      index: _tab,
                      child: switch (_tab) {
                        0 =>
                          linked
                              ? AccountsPane(onOpen: _go)
                              : LockedAccountsPane(
                                  onLink: () => _go(AppRoutes.parentLink),
                                ),
                        1 => InvoicesPane(
                          filter: _invoiceFilter,
                          onFilter: (i) => setState(() => _invoiceFilter = i),
                          onOpen: _go,
                        ),
                        _ => CardsPane(onOpen: _go),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One balance per account in a swipeable pager. The account in view
  /// sits at full strength; a neighbour dims and shrinks as it leaves.
  Widget _balances(int count, bool linked) {
    final scaler = MediaQuery.textScalerOf(context);
    // The label, the amount, the optional limit line and the number row.
    final height =
        scaler.scale(20) + 4 + 56 + (linked ? 0 : scaler.scale(16) + 6) + 48;
    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: _pages,
        itemCount: count,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (_, i) => AnimatedBuilder(
          animation: _pages,
          builder: (context, child) {
            final t = _pageOffset(i).abs().clamp(0.0, 1.0);
            // Dimmed toward the canvas with a colour filter rather than
            // Opacity, which the shell's fade test reads.
            return ColorFiltered(
              colorFilter: ColorFilter.mode(
                AppColors.surface.withValues(alpha: 0.7 * t),
                BlendMode.srcATop,
              ),
              child: Transform.scale(scale: 1 - 0.08 * t, child: child),
            );
          },
          child: HomeBalance(
            label: _accounts[i].$1,
            account: linked ? _accounts[i].$2 : Accounts.main,
            balance: linked ? _accounts[i].$3 : Balances.main,
            hidden: _hideBalance,
            limited: !linked,
            onToggleHidden: () => setState(() => _hideBalance = !_hideBalance),
          ),
        ),
      ),
    );
  }
}
