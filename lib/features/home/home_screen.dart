import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

/// "PocketPal Kid Home" from Stitch. With [parentLinked] false it renders the
/// "Эцэг эх холбогдоогүй" variant: limited balance, locked accounts and a
/// banner prompting to link a parent.
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

  static const _cards = [
    ('MN •••• 3389', 567930, Mascots.bearCard),
    ('MN •••• 8201', 1280000, Mascots.puppyPiggy),
    ('MN •••• 8202', 142500, Mascots.otterInvest),
    ('MN •••• 8203', 35000, Mascots.redPandaTrophy),
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(String route) => context.push(route);

  @override
  Widget build(BuildContext context) {
    final linked = widget.parentLinked;
    return ColoredBox(
      color: kPageBackground,
      child: Column(
        children: [
          _Header(
            linked: linked,
            onNotifications: () => _go(AppRoutes.notifications),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                120 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                _PageDots(count: linked ? _cards.length : 4, index: _page),
                const SizedBox(height: 12),
                if (!linked && _bannerVisible) ...[
                  _LinkParentBanner(
                    onClose: () => setState(() => _bannerVisible = false),
                    onLink: () => _go(AppRoutes.parentLink),
                  ),
                  const SizedBox(height: 14),
                ],
                SizedBox(
                  height: 232,
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: linked ? _cards.length : 1,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _BalanceCard(
                        account: linked ? _cards[i].$1 : 'MN •••• 3389',
                        balance: linked ? _cards[i].$2 : 20000,
                        mascot: _cards[i].$3,
                        hidden: _hideBalance,
                        limited: !linked,
                        onToggleHidden: () =>
                            setState(() => _hideBalance = !_hideBalance),
                        onTransfer: () => _go(AppRoutes.transfer),
                        onTopUp: () => _go(AppRoutes.requestMoney),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedTabs(
                  labels: const ['Данс', 'Нэхэмжлэх', 'Карт'],
                  index: _tab,
                  dotOnActive: true,
                  onChanged: (i) => setState(() => _tab = i),
                ),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: switch (_tab) {
                    0 =>
                      linked
                          ? _AccountsPane(key: const ValueKey(0), onOpen: _go)
                          : _LockedAccountsPane(
                              key: const ValueKey(3),
                              onLink: () => _go(AppRoutes.parentLink),
                            ),
                    1 => _InvoicesPane(
                      key: const ValueKey(1),
                      filter: _invoiceFilter,
                      onFilter: (i) => setState(() => _invoiceFilter = i),
                      onOpen: _go,
                    ),
                    _ => _CardsPane(key: const ValueKey(2), onOpen: _go),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.linked, required this.onNotifications});

  final bool linked;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      decoration: BoxDecoration(
        color: kPageBackground.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: AppColors.sky100.withValues(alpha: 0.6)),
        ),
      ),
      child: SizedBox(
        height: 68,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sky100,
                  border: Border.all(
                    color: AppColors.sky500.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    Mascots.bearSitting,
                    fit: BoxFit.cover,
                    semanticLabel: 'Тэмүүлэн',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Сайн уу 👋',
                      style: comfortaa(
                        size: 11,
                        weight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                    Text(
                      'Тэмүүлэн!',
                      style: comfortaa(
                        size: 17,
                        weight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (!linked)
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: StatusBadge(
                          label: 'Эцэг эх холбогдоогүй',
                          tone: BadgeTone.amber,
                        ),
                      ),
                  ],
                ),
              ),
              CircleIconButton(
                icon: Icons.notifications_none_rounded,
                label: 'Мэдэгдэл',
                badge: true,
                onPressed: onNotifications,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index ? AppColors.sky500 : AppColors.sky200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.account,
    required this.balance,
    required this.mascot,
    required this.hidden,
    required this.limited,
    required this.onToggleHidden,
    required this.onTransfer,
    required this.onTopUp,
  });

  final String account;
  final int balance;
  final String mascot;
  final bool hidden;
  final bool limited;
  final VoidCallback onToggleHidden;
  final VoidCallback onTransfer;
  final VoidCallback onTopUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.sky100.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -14,
            top: -12,
            child: MascotImage(
              asset: mascot,
              size: 130,
              background: Colors.white,
              semanticLabel: 'Бамбарууш',
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sky50,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.sky100.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      account,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _TinyIcon(
                    icon: Icons.content_copy_rounded,
                    label: 'Данс хуулах',
                    onTap: () {
                      Clipboard.setData(
                        const ClipboardData(text: 'MN5049821903389'),
                      );
                      showAppSnack(context, 'Дансны дугаар хуулагдлаа');
                    },
                  ),
                  _TinyIcon(
                    icon: hidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    label: hidden ? 'Үлдэгдэл харах' : 'Үлдэгдэл нуух',
                    onTap: onToggleHidden,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: hidden
                    ? Text(
                        '••••••••',
                        style: moneyStyle(size: 30, letterSpacing: 4),
                      )
                    : Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '₮',
                              style: moneyStyle(
                                size: 28,
                                weight: FontWeight.w600,
                                color: AppColors.slate700,
                              ),
                            ),
                            TextSpan(
                              text: formatMnt(balance).substring(1),
                              style: moneyStyle(size: 34, letterSpacing: -0.8),
                            ),
                          ],
                        ),
                      ),
              ),
              if (limited)
                Text(
                  'Хязгаарлагдмал горимын үлдэгдэл',
                  style: comfortaa(
                    size: 10,
                    weight: FontWeight.w600,
                    color: AppColors.amber500,
                  ),
                ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _CardAction(
                      label: 'Гүйлгээ',
                      mascot: Mascots.foxPhone,
                      primary: false,
                      onTap: onTransfer,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CardAction(
                      label: 'Цэнэглэх',
                      mascot: Mascots.bunnyBattery,
                      primary: true,
                      onTap: onTopUp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TinyIcon extends StatelessWidget {
  const _TinyIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: AppColors.slate400),
        ),
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.label,
    required this.mascot,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final String mascot;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.95,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: primary ? AppColors.sky500 : AppColors.sky50,
            borderRadius: BorderRadius.circular(18),
            border: primary
                ? null
                : Border.all(color: AppColors.sky100.withValues(alpha: 0.8)),
            boxShadow: primary
                ? [
                    BoxShadow(
                      color: AppColors.sky500.withValues(alpha: 0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(2),
                child: MascotImage(
                  asset: mascot,
                  size: 26,
                  background: Colors.white,
                  semanticLabel: '',
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: comfortaa(
                  size: 13,
                  weight: FontWeight.w700,
                  color: primary ? Colors.white : AppColors.slate700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.title,
    required this.subtitle,
    required this.mascot,
    this.amount,
    this.badge,
    this.onTap,
    this.tileColor = Colors.white,
    this.trailing,
    this.locked = false,
  });

  final String title;
  final String subtitle;
  final String mascot;
  final String? amount;
  final Widget? badge;
  final VoidCallback? onTap;
  final Color tileColor;
  final Widget? trailing;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      radius: 18,
      color: locked ? AppColors.slate50 : Colors.white,
      borderColor: locked ? AppColors.slate200 : AppColors.sky100,
      dashed: locked,
      shadow: !locked,
      child: Opacity(
        opacity: locked ? 0.85 : 1,
        child: Row(
          children: [
            MascotTile(asset: mascot, background: tileColor, label: title),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        title,
                        style: comfortaa(
                          size: 13,
                          weight: FontWeight.w700,
                          color: locked
                              ? AppColors.slate600
                              : AppColors.slate800,
                        ),
                      ),
                      ?badge,
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: comfortaa(
                      size: 11,
                      weight: FontWeight.w500,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else ...[
              Text(amount ?? '', style: moneyStyle(size: 14)),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.slate400,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccountsPane extends StatelessWidget {
  const _AccountsPane({super.key, required this.onOpen});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AccountRow(
          title: 'Хадгаламжийн данс',
          subtitle: 'MN 5049 8219 01',
          mascot: Mascots.puppyPiggy,
          amount: '₮1,280,000',
          onTap: () => onOpen(AppRoutes.savingsAccount),
        ),
        const SizedBox(height: 10),
        _AccountRow(
          title: 'Хувьцаа данс',
          subtitle: 'MN 5049 8219 02',
          mascot: Mascots.foxPhone,
          amount: '₮142,500',
          onTap: () => onOpen(AppRoutes.stocks),
        ),
        const SizedBox(height: 10),
        _AccountRow(
          title: 'Урамшууллын данс',
          subtitle: 'MN 5049 8219 03',
          mascot: Mascots.owlBook,
          amount: '₮35,000',
          onTap: () => onOpen(AppRoutes.rewardsAccount),
        ),
        const SizedBox(height: 10),
        _AccountRow(
          title: 'Ард койны данс',
          subtitle: 'MN 5049 8219 04',
          mascot: Mascots.bunnyCoin,
          tileColor: AppColors.amber50,
          amount: '₮50,000',
          badge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.amber500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.amber200),
            ),
            child: Text(
              '1 Койн = 1₮',
              style: comfortaa(
                size: 9,
                weight: FontWeight.w700,
                color: AppColors.amber600,
              ),
            ),
          ),
          onTap: () => onOpen(AppRoutes.coinAccount),
        ),
      ],
    );
  }
}

class _LockedAccountsPane extends StatelessWidget {
  const _LockedAccountsPane({super.key, required this.onLink});

  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    Widget linkButton() => GestureDetector(
      onTap: onLink,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.sky50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.sky200.withValues(alpha: 0.6)),
        ),
        child: Text(
          'Эцэг эх холбох',
          style: comfortaa(
            size: 10,
            weight: FontWeight.w700,
            color: AppColors.sky600,
          ),
        ),
      ),
    );

    Widget status(String amount, String label, Color amountColor, Color c) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: moneyStyle(size: 13, color: amountColor)),
            const SizedBox(height: 2),
            Text(
              label,
              style: comfortaa(size: 9, weight: FontWeight.w700, color: c),
            ),
          ],
        );

    return Column(
      children: [
        _AccountRow(
          title: 'Халаасны үндсэн данс',
          subtitle: 'MN 5049 8219 01',
          mascot: Mascots.bearCard,
          tileColor: AppColors.sky50,
          trailing: status(
            '₮20,000',
            '● Идэвхтэй',
            AppColors.slate800,
            AppColors.emerald600,
          ),
        ),
        const SizedBox(height: 10),
        _AccountRow(
          title: 'Хадгаламжийн данс',
          subtitle: 'Холболт шаардлагатай',
          mascot: Mascots.bearStar,
          tileColor: AppColors.amber50,
          locked: true,
          trailing: linkButton(),
        ),
        const SizedBox(height: 10),
        _AccountRow(
          title: 'Хувьцаа данс',
          subtitle: 'MN 5049 8219 02',
          mascot: Mascots.foxPhone,
          tileColor: AppColors.sky50,
          locked: true,
          trailing: linkButton(),
        ),
        const SizedBox(height: 10),
        _AccountRow(
          title: 'Урамшууллын данс',
          subtitle: 'Эхлэлийн урамшуулал',
          mascot: Mascots.owlBook,
          tileColor: AppColors.amber50,
          trailing: status(
            '₮10,000',
            'Идэвхтэй',
            AppColors.amber500,
            AppColors.slate400,
          ),
        ),
        const SizedBox(height: 10),
        _AccountRow(
          title: 'Койны данс',
          subtitle: 'MN 5049 8219 04',
          mascot: Mascots.bunnyCoin,
          tileColor: AppColors.amber50,
          locked: true,
          trailing: linkButton(),
        ),
      ],
    );
  }
}

class _LinkParentBanner extends StatelessWidget {
  const _LinkParentBanner({required this.onClose, required this.onLink});

  final VoidCallback onClose;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: null,
      child: AppCard(
        dashed: true,
        borderColor: AppColors.amber400,
        color: AppColors.amber50,
        radius: 24,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Эцэг эхтэйгээ холбогдох',
                        style: comfortaa(
                          size: 12,
                          weight: FontWeight.w700,
                          color: AppColors.amber800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Эрхээ 5 дахин нэмэгдүүлж, хадгаламж болон урамшууллын дансаа идэвхжүүлээрэй!',
                        style: comfortaa(
                          size: 11,
                          color: AppColors.slate600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Хаах',
                  child: GestureDetector(
                    onTap: onClose,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.slate400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.amber100),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Өдрийн лимит: ',
                        children: [
                          TextSpan(
                            text: '₮20,000 / ₮20,000',
                            style: comfortaa(
                              size: 10,
                              weight: FontWeight.w700,
                              color: AppColors.amber600,
                            ),
                          ),
                        ],
                      ),
                      style: comfortaa(
                        size: 10,
                        weight: FontWeight.w500,
                        color: AppColors.slate500,
                      ),
                    ),
                  ),
                  const StatusBadge(
                    label: 'Хязгаарлагдмал',
                    tone: BadgeTone.amber,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Эцэг эхээ холбох 🚀',
              height: 40,
              onPressed: onLink,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoicesPane extends StatelessWidget {
  const _InvoicesPane({
    super.key,
    required this.filter,
    required this.onFilter,
    required this.onOpen,
  });

  final int filter;
  final ValueChanged<int> onFilter;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final invoices = [
      (
        'Ээжээс халаасны мөнгө',
        Mascots.catHeart,
        'Хүлээгдэж буй',
        AppColors.amber500,
        '₮20,000',
        'Өнөөдөр',
        0,
      ),
      (
        'Ном, дэвтэр авах',
        Mascots.bearBooks,
        'Зөвшөөрсөн / Төлөх',
        AppColors.emerald500,
        '₮18,500',
        'Өчигдөр',
        1,
      ),
      (
        'Ааваас даалгаврын урамшуулал',
        Mascots.owlBook,
        'Батлагдсан ✔',
        AppColors.sky500,
        '₮10,000',
        '+ Олсон',
        2,
      ),
    ];
    final visible = invoices.where(
      (e) => switch (filter) {
        1 => e.$7 < 2,
        2 => e.$7 == 2,
        _ => true,
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 6,
          children: [
            for (final (i, l) in [
              'Бүгд (3)',
              'Хүлээгдэж буй (2)',
              'Төлөгдсөн (1)',
            ].indexed)
              FilterChipPill(
                label: l,
                selected: filter == i,
                onTap: () => onFilter(i),
              ),
          ],
        ),
        const SizedBox(height: 10),
        for (final inv in visible) ...[
          AppCard(
            radius: 18,
            child: Column(
              children: [
                Row(
                  children: [
                    MascotTile(asset: inv.$2, label: inv.$1),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inv.$1,
                            style: comfortaa(size: 13, weight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: inv.$4,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  inv.$3,
                                  style: comfortaa(
                                    size: 11,
                                    weight: FontWeight.w600,
                                    color: inv.$7 == 0
                                        ? AppColors.slate500
                                        : inv.$4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(inv.$5, style: moneyStyle(size: 14)),
                        Text(
                          inv.$6,
                          style: comfortaa(
                            size: 11,
                            color: inv.$7 == 2
                                ? AppColors.emerald600
                                : AppColors.slate400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (inv.$7 < 2) ...[
                  const Divider(height: 20, color: AppColors.slate100),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          inv.$7 == 0
                              ? 'Ээжид мэдэгдэл илгээх'
                              : 'Дэлгүүрийн нэхэмжлэх',
                          style: comfortaa(size: 11, color: AppColors.slate400),
                        ),
                      ),
                      inv.$7 == 0
                          ? SoftButton(
                              label: 'Сануулах',
                              icon: Icons.notifications_active_outlined,
                              height: 30,
                              onPressed: () => showAppSnack(
                                context,
                                'Ээжид сануулга илгээлээ',
                              ),
                            )
                          : SoftButton(
                              label: 'Төлөх',
                              icon: Icons.payments_outlined,
                              height: 30,
                              background: AppColors.sky500,
                              foreground: Colors.white,
                              border: null,
                              onPressed: () => onOpen(AppRoutes.cart),
                            ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        _DashedAction(
          icon: Icons.add_circle_outline_rounded,
          label: 'Шинэ нэхэмжлэх / хүсэлт үүсгэх',
          onTap: () => onOpen(AppRoutes.requestMoney),
        ),
      ],
    );
  }
}

class _CardsPane extends StatelessWidget {
  const _CardsPane({super.key, required this.onOpen});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          radius: 18,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _IconTile(
                icon: Icons.credit_card_rounded,
                background: AppColors.sky100,
                color: AppColors.sky600,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TwoLine(
                  title: 'PocketPal Junior Card',
                  subtitle: '•••• 5521',
                ),
              ),
              const StatusBadge(label: 'Идэвхтэй', tone: BadgeTone.emerald),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          radius: 18,
          padding: const EdgeInsets.all(16),
          onTap: () => onOpen(AppRoutes.cardOrder),
          child: Column(
            children: [
              Row(
                children: [
                  _IconTile(
                    icon: Icons.credit_card_rounded,
                    background: AppColors.amber500.withValues(alpha: 0.1),
                    color: AppColors.amber500,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TwoLine(
                      title: 'PocketPal Custom Neon Card',
                      subtitle: '•••• 8820',
                    ),
                  ),
                  const StatusBadge(
                    label: 'Хүлээгдэж буй',
                    tone: BadgeTone.amber,
                    icon: Icons.schedule_rounded,
                  ),
                ],
              ),
              const Divider(height: 20, color: AppColors.slate100),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.amber500,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Эцэг эхийн зөвшөөрөл хүлээж байна',
                      style: comfortaa(size: 11, color: AppColors.slate400),
                    ),
                  ),
                  Text(
                    'Дэлгэрэнгүй',
                    style: comfortaa(
                      size: 11,
                      weight: FontWeight.w700,
                      color: AppColors.sky600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _DashedAction(
          icon: Icons.add_card_rounded,
          label: 'Шинэ загварын хүүхдийн карт захиалах ✨',
          onTap: () => onOpen(AppRoutes.cardOrder),
        ),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.background,
    required this.color,
  });

  final IconData icon;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _TwoLine extends StatelessWidget {
  const _TwoLine({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: comfortaa(size: 13, weight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(subtitle, style: comfortaa(size: 11, color: AppColors.slate400)),
      ],
    );
  }
}

class _DashedAction extends StatelessWidget {
  const _DashedAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      dashed: true,
      borderColor: AppColors.sky200,
      radius: 18,
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.sky600),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: comfortaa(
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.sky600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
