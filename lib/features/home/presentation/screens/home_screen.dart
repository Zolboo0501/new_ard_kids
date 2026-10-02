import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/accounts.dart';
import '../../../../app/avatar.dart';
import '../../../../app/kid_profile.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/ui.dart';
import '../../../../widgets/entrance.dart';
import '../../data/card_art.dart';
import '../widgets/account_panel.dart';
import '../widgets/accounts_pane.dart';
import '../widgets/balance_card.dart';
import '../widgets/cards_pane.dart';
import '../widgets/home_header.dart';
import '../widgets/invoices_pane.dart';
import '../widgets/locked_accounts_pane.dart';
import '../widgets/page_dots.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.parentLinked = true});

  final bool parentLinked;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pages = PageController(viewportFraction: 0.92);
  int _page = 0;
  int _tab = 0;
  int _invoiceFilter = 0;
  bool _hideBalance = false;

  /// Every account in the carousel: label, number, balance, the colour
  /// its panel glows in, its glyph, a short line about what it is for and
  /// an optional picture that replaces the glyph.
  static List<(String, String, int, Color, LineGlyph, String, String?)>
  get _cards => [
    (
      'Харилцах данс',
      Accounts.main,
      Balances.main,
      AppColors.sky500,
      LineGlyph.pocket,
      'Өдөр тутмын зарлага',
      null,
    ),
    (
      'Хадгаламж данс',
      Accounts.savings,
      Balances.savings,
      AppColors.violet500,
      LineGlyph.piggy,
      'Хуримтлал',
      null,
    ),
    (
      'Миний өв',
      Accounts.stocks,
      Balances.stocks,
      AppColors.lime500,
      LineGlyph.sprout,
      'Хөрөнгө оруулалт',
      null,
    ),
    (
      'Урамшууллын данс',
      Accounts.rewards,
      Balances.rewards,
      AppColors.pink500,
      LineGlyph.gift,
      'Оноо, урамшуулал',
      null,
    ),
    (
      'Ард койн данс',
      Accounts.coin,
      Balances.coins,
      AppColors.amber500,
      LineGlyph.ardCoin,
      '1 Койн = 1₮',
      null,
    ),
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
      ('Гүйлгээ', LineGlyph.paperPlane, () => _go(AppRoutes.transfer)),
      (
        'Мөнгө хүсэх',
        LineGlyph.arrowDownLeft,
        () => _go(AppRoutes.requestMoney),
      ),
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
    final count = linked ? _cards.length : 1;
    final current = _cards[linked ? _page : 0];
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
              // Split on wide windows: the card and balance stay on the left
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
                    _carousel(count, linked),
                    if (linked) ...[
                      const SizedBox(height: 10),
                      PageDots(count: count, index: _page),
                    ],
                    const SizedBox(height: 18),
                    HomeBalance(
                      label: current.$1,
                      account: linked ? current.$2 : Accounts.main,
                      balance: linked ? current.$3 : Balances.main,
                      hidden: _hideBalance,
                      limited: !linked,
                      onToggleHidden: () =>
                          setState(() => _hideBalance = !_hideBalance),
                    ),
                    const SizedBox(height: 20),
                    HomeActions(
                      actions: _actions(linked ? current.$2 : Accounts.main),
                      art: accountActionArt,
                    ),
                  ],
                  trailing: [
                    AppTabs(
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

  /// The account panels over a soft glow in the selected account's colour.
  /// Each panel spans most of the width at a fixed height; neighbours peek
  /// in at the sides and shrink as they leave.
  Widget _carousel(int count, bool linked) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The height a bank-card-shaped panel at 80% of the width would
        // have; the panels themselves are wider (92%) at that height.
        final height = (constraints.maxWidth * 0.8 - 28) / 1.586 + 24;
        final glow = _cards[linked ? _page : 0].$4;
        return SizedBox(
          height: height,
          child: Stack(
            // The glow spills past the carousel, into the page around it.
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // The glow, cross-fading to the next account's colour. It is
              // positioned past the carousel's bounds so it spills around
              // the card instead of hiding under it.
              Positioned(
                left: 0,
                right: 0,
                top: -14,
                bottom: -14,
                child: TweenAnimationBuilder<Color?>(
                  duration: const Duration(milliseconds: 420),
                  curve: appEmphasizedDecelerate,
                  tween: ColorTween(end: glow),
                  // A soft light behind the card, brightest at its centre and
                  // spilling well past its edges.
                  // A circle stretched sideways into a wide ellipse, so the
                  // light reaches past the card's sides but has fully faded
                  // before the list's top and bottom edges.
                  builder: (context, c, _) => IgnorePointer(
                    child: Transform.scale(
                      scaleX: 1.9,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(-0.04, 0),
                            radius: 0.5,
                            colors: [
                              (c ?? glow).withValues(alpha: 0.28),
                              (c ?? glow).withValues(alpha: 0.1),
                              (c ?? glow).withValues(alpha: 0),
                            ],
                            stops: const [0.35, 0.7, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              PageView.builder(
                controller: _pages,
                itemCount: count,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => AnimatedBuilder(
                  animation: _pages,
                  builder: (context, child) {
                    final t = _pageOffset(i).abs().clamp(0.0, 1.0);
                    // Dimmed toward the canvas with a colour filter
                    // rather than Opacity, which the shell's fade test reads.
                    return ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        AppColors.surface.withValues(alpha: 0.55 * t),
                        BlendMode.srcATop,
                      ),
                      child: Transform.scale(scale: 1 - 0.1 * t, child: child),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                    child: HomeAccountPanel(
                      aspectRatio: null,
                      label: _cards[i].$1,
                      account: _cards[i].$2,
                      accent: _cards[i].$4,
                      icon: _cards[i].$5,
                      subtitle: _cards[i].$6,
                      image: _cards[i].$7,
                      background: accountCardArt(_cards[i].$2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
