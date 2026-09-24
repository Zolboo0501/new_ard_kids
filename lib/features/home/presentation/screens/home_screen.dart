import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/accounts.dart';
import '../../../../app/avatar.dart';
import '../../../../app/routes.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/accounts_pane.dart';
import '../widgets/balance_card.dart';
import '../widgets/cards_pane.dart';
import '../widgets/home_header.dart';
import '../widgets/invoices_pane.dart';
import '../widgets/link_parent_banner.dart';
import '../widgets/locked_accounts_pane.dart';
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
  bool _bannerVisible = true;

  /// The balance cards, each shown with its label and the chosen
  /// companion's image for it.
  static List<(String, String, int, String)> _cards(AppAvatar a) => [
    ('Харилцах данс', Accounts.main, 567930, a.pick),
    ('Хадгаламж данс', Accounts.savings, 1280000, a.savings),
    ('Урамшууллын данс', Accounts.rewards, 35000, a.rewards),
    ('Ард койн данс', Accounts.coin, 50000, Stickers.coins),
  ];

  @override
  void initState() {
    super.initState();
    appAvatar.addListener(_onAvatarChanged);
  }

  void _onAvatarChanged() => setState(() {});

  @override
  void dispose() {
    appAvatar.removeListener(_onAvatarChanged);
    _pages.dispose();
    super.dispose();
  }

  void _go(String route) => context.push(route);

  /// The buttons along the bottom of [account]'s balance card; the last is
  /// the primary one.
  List<(String, String, VoidCallback)> _actions(String account) =>
      switch (account) {
        Accounts.savings => [
          ('Орлого', Stickers.receive, () => _go(AppRoutes.savingsDeposit)),
          ('Дэлгэрэнгүй', Stickers.piggy, () => _go(AppRoutes.savingsAccount)),
        ],
        Accounts.rewards => [
          ('Найз урих', Stickers.addFriend, () => _go(AppRoutes.inviteFriends)),
          ('Дэлгэрэнгүй', Stickers.gift, () => _go(AppRoutes.rewardsAccount)),
        ],
        Accounts.coin => [
          ('Дэлгэрэнгүй', Stickers.coin, () => _go(AppRoutes.coinAccount)),
        ],
        _ => [
          ('Гүйлгээ', Stickers.transfer, () => _go(AppRoutes.transfer)),
          ('Цэнэглэх', Stickers.receive, () => _go(AppRoutes.requestMoney)),
        ],
      };

  /// How far card [i] sits from the centre of the carousel, in pages:
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
    final cards = _cards(avatar);
    return ColoredBox(
      color: kPageBackground,
      child: Column(
        children: [
          HomeHeader(
            linked: linked,
            avatar: avatar,
            onNotifications: () => _go(AppRoutes.notifications),
          ),
          Expanded(
            child: EntranceScope(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  120 + MediaQuery.paddingOf(context).bottom,
                ),
                children: EntranceItem.list([
                  PageDots(count: linked ? cards.length : 4, index: _page),
                  const SizedBox(height: 12),
                  if (!linked && _bannerVisible) ...[
                    LinkParentBanner(
                      onClose: () => setState(() => _bannerVisible = false),
                      onLink: () => _go(AppRoutes.parentLink),
                    ),
                    const SizedBox(height: 14),
                  ],
                  SizedBox(
                    // Unlinked cards add the "Хязгаарлагдмал" line.
                    height: linked ? 232 : 246,
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: linked ? cards.length : 1,
                      onPageChanged: (i) => setState(() => _page = i),
                      // Each card follows the swipe: the one leaving shrinks
                      // and dims while the next grows in, and the mascot
                      // lags behind the card for a touch of depth.
                      itemBuilder: (_, i) => AnimatedBuilder(
                        animation: _pages,
                        builder: (context, child) {
                          final offset = _pageOffset(i);
                          final t = offset.abs().clamp(0.0, 1.0);
                          return Opacity(
                            opacity: 1 - 0.35 * t,
                            child: Transform.scale(
                              scale: 1 - 0.08 * t,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                child: BalanceCard(
                                  label: cards[i].$1,
                                  account: linked ? cards[i].$2 : Accounts.main,
                                  balance: linked ? cards[i].$3 : 20000,
                                  mascot: cards[i].$4,
                                  mascotName: avatar.name,
                                  mascotShift: offset,
                                  hidden: _hideBalance,
                                  limited: !linked,
                                  onToggleHidden: () => setState(
                                    () => _hideBalance = !_hideBalance,
                                  ),
                                  actions: _actions(
                                    linked ? cards[i].$2 : Accounts.main,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTabs(
                    tabs: const [
                      AppTab('Данс'),
                      AppTab('Нэхэмжлэх'),
                      AppTab('Карт'),
                    ],
                    index: _tab,
                    dotOnActive: true,
                    style: AppTabsStyle.card,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                  const SizedBox(height: 14),
                  AppTabView(
                    index: _tab,
                    child: switch (_tab) {
                      0 =>
                        linked
                            ? AccountsPane(avatar: avatar, onOpen: _go)
                            : LockedAccountsPane(
                                avatar: avatar,
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
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
