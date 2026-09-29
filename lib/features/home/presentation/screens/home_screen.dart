import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/accounts.dart';
import '../../../../app/avatar.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/ui.dart';
import '../../../../widgets/entrance.dart';
import '../widgets/account_panel.dart';
import '../widgets/accounts_pane.dart';
import '../widgets/balance_card.dart';
import '../widgets/cards_pane.dart';
import '../../../savings/data/savings_goal.dart';
import '../widgets/home_header.dart';
import '../widgets/home_hero.dart';
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
  final _pages = PageController(viewportFraction: 0.8);
  int _page = 0;
  int _tab = 0;
  int _invoiceFilter = 0;
  bool _hideBalance = false;
  bool _bannerVisible = true;

  /// Every account in the carousel: label, number, balance, the colour
  /// its panel glows in, its glyph, a short line about what it is for and
  /// an optional picture that replaces the glyph.
  static List<(String, String, int, Color, LineGlyph, String, String?)>
  get _cards => [
    (
      'Харилцах данс',
      Accounts.main,
      567930,
      AppColors.sky500,
      LineGlyph.pocket,
      'Өдөр тутмын зарлага',
      null,
    ),
    (
      'Хадгаламж данс',
      Accounts.savings,
      1280000,
      Night.violet,
      LineGlyph.piggy,
      'Хуримтлал үүсгээрэй',
      null,
    ),
    (
      'Миний өв',
      Accounts.stocks,
      142500,
      Night.lime,
      LineGlyph.sprout,
      'Хөрөнгө оруулалт',
      null,
    ),
    (
      'Урамшууллын данс',
      Accounts.rewards,
      35000,
      Night.pink,
      LineGlyph.gift,
      'Оноо, урамшуулал',
      null,
    ),
    (
      'Ард койн данс',
      Accounts.coin,
      50000,
      Night.amber,
      LineGlyph.ardCoin,
      '1 Койн = 1₮',
      Mascots.ardCoin3d,
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

  /// The selected account's buttons; the first is the mint one.
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
      ('Цэнэглэх', LineGlyph.charge, () => _go(AppRoutes.requestMoney)),
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
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: Night.bg,
        child: Column(
          children: [
            HomeHeader(
              linked: linked,
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
                    const SizedBox(height: 10),
                    PageDots(count: _cards.length, index: _page),
                    const SizedBox(height: 18),
                    HomeBalance(
                      label: current.$1,
                      account: linked ? current.$2 : Accounts.main,
                      balance: linked ? current.$3 : 20000,
                      hidden: _hideBalance,
                      limited: !linked,
                      onToggleHidden: () =>
                          setState(() => _hideBalance = !_hideBalance),
                    ),
                    const SizedBox(height: 20),
                    HomeActions(
                      actions: _actions(linked ? current.$2 : Accounts.main),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The mascot with the kid's streak and nearest savings goal. Unlinked
  /// kids have no savings yet, so they're invited to set their first goal.
  Widget _hero(bool linked) {
    if (!linked) {
      return HomeHero(streakDays: 1, onTap: () => _go(AppRoutes.newGoal));
    }
    final goal = kSampleGoals.first;
    return HomeHero(
      streakDays: 7,
      goal: goal.title,
      saved: goal.saved,
      target: goal.target,
      onTap: () => _go(AppRoutes.savingsAccount),
    );
  }

  /// The account panels over a soft glow in the selected account's colour.
  /// Neighbouring panels peek in at the sides and shrink as they leave.
  Widget _carousel(int count, bool linked) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth * 0.8 - 28;
        final height = cardWidth / 1.586 + 24;
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
                              (c ?? glow).withValues(alpha: 0.5),
                              (c ?? glow).withValues(alpha: 0.2),
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
                    // Dimmed toward the black canvas with a colour filter
                    // rather than Opacity, which the shell's fade test reads.
                    return ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Night.bg.withValues(alpha: 0.55 * t),
                        BlendMode.srcATop,
                      ),
                      child: Transform.scale(scale: 1 - 0.1 * t, child: child),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: HomeAccountPanel(
                      label: _cards[i].$1,
                      account: _cards[i].$2,
                      accent: _cards[i].$4,
                      icon: _cards[i].$5,
                      subtitle: _cards[i].$6,
                      image: _cards[i].$7,
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
