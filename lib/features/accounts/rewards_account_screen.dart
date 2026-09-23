import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/accounts.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'account_widgets.dart';
import 'coin_account_screen.dart';
import '../../widgets/app_tabs.dart';
import '../../widgets/app_text.dart';
import '../../widgets/entrance.dart';
import '../../app/avatar.dart';

/// "Урамшууллын данс - Минимал": rewards balance and history, with the coin
/// account ([CoinAccountPane]) as a second tab. [initialTab] 1 opens straight
/// on coins, which is what [AppRoutes.coinAccount] does.
class RewardsAccountScreen extends StatefulWidget {
  const RewardsAccountScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<RewardsAccountScreen> createState() => _RewardsAccountScreenState();
}

class _RewardsAccountScreenState extends State<RewardsAccountScreen> {
  late int _tab = widget.initialTab;

  /// The eye button's state, shared by both tabs: hides every account
  /// number and balance on the screen.
  bool _hidden = false;

  void _toggleHidden() => setState(() => _hidden = !_hidden);

  @override
  Widget build(BuildContext context) {
    final coins = _tab == 1;
    return Scaffold(
      backgroundColor: kPageBackground,
      appBar: SubPageHeader(
        // The title names the account the selected tab shows.
        title: coins ? 'Койны данс' : 'Урамшууллын данс',
        trailing: coins
            ? CircleIconButton(
                icon: Icons.calendar_month_outlined,
                label: 'Огноо шүүлтүүр',
                onPressed: () => showAppSnack(context, 'Огноо сонгох'),
              )
            : null,
      ),
      body: EntranceScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            AppTabs(
              tabs: const [AppTab('Урамшуулал'), AppTab('Койн')],
              index: _tab,
              dotOnActive: true,
              style: AppTabsStyle.card,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 14),
            AppTabView(
              index: _tab,
              child: coins
                  ? CoinAccountPane(
                      hidden: _hidden,
                      onToggleHidden: _toggleHidden,
                    )
                  : _RewardsPane(
                      hidden: _hidden,
                      onToggleHidden: _toggleHidden,
                      onOpen: (r) => context.push(r),
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _RewardsPane extends StatelessWidget {
  const _RewardsPane({
    required this.hidden,
    required this.onToggleHidden,
    required this.onOpen,
  });

  final bool hidden;
  final VoidCallback onToggleHidden;
  final ValueChanged<String> onOpen;

  static List<TxItem> get _items => [
    TxItem(
      title: 'Гэрийн даалгавраа онц хийсэн',
      subtitle: 'Ааваас олгосон',
      when: 'Өнөөдөр',
      amount: 10000,
      asset: Mascots.owlBook,
      tint: AppColors.sky50,
    ),
    TxItem(
      title: 'Хадгаламжийн зорилгодоо хүрсэн',
      subtitle: 'Ээжийн нэмэгдэл',
      when: 'Өчигдөр',
      amount: 15000,
      asset: Mascots.bearConfetti,
      tint: AppColors.amber50,
    ),
    TxItem(
      title: 'Найзаа урьж бүртгүүлсэн',
      subtitle: 'Урамшуулал',
      when: '05.12',
      amount: 5000,
      asset: Stickers.gift,
      tint: AppColors.orange50,
      badge: 'Амжилттай',
      badgeTone: BadgeTone.amber,
    ),
    TxItem(
      title: 'Ном унших сарын челленж',
      subtitle: 'Сургуулийн даалгавар',
      when: '05.10',
      amount: 10000,
      asset: Mascots.owlMedal,
      tint: AppColors.violet50,
      badge: 'Биелүүлсэн',
    ),
    TxItem(
      title: 'Интерном эрхийн бичиг авсан',
      subtitle: 'Бэлэг худалдан авалт',
      when: '05.08',
      amount: -20000,
      asset: Mascots.bearBooks,
      tint: AppColors.rose50,
      badge: 'Зарцуулсан',
      badgeTone: BadgeTone.slate,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = _items;
    // Summed from the history below, so the card and the list agree.
    final earned = items
        .where((i) => i.income)
        .fold<int>(0, (sum, i) => sum + i.amount);
    final spent = items
        .where((i) => !i.income)
        .fold<int>(0, (sum, i) => sum - i.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Same structure as the coin card (number, balance beside the
        // mascot, then the totals) so switching tabs changes the content,
        // not the layout; the warm amber keeps the two accounts apart.
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, AppColors.amber50],
            ),
            border: Border.all(color: AppColors.amber100),
            boxShadow: [
              BoxShadow(
                color: AppColors.amber500.withValues(alpha: 0.08),
                offset: const Offset(0, 10),
                blurRadius: 24,
                spreadRadius: -8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CopyAccountNumber(
                number: Accounts.rewards,
                prefix: 'Данс: ',
                hidden: hidden,
                onToggleHidden: onToggleHidden,
                style: moneyStyle(
                  size: 12,
                  weight: FontWeight.w500,
                  color: AppColors.slate500,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Нийт үлдэгдэл',
                          size: 12,
                          weight: FontWeight.w500,
                          color: AppColors.slate500,
                        ),
                        const SizedBox(height: 2),
                        HideableBalance(
                          hidden: hidden,
                          balance: const BalanceText(
                            35000,
                            animateFrom: 0,
                            size: 30,
                            currencyWeight: FontWeight.w600,
                            currencyColor: AppColors.slate700,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MascotImage(
                    asset: Stickers.gift,
                    size: 100,
                    background: Color(0xFFFFFCF2),
                    semanticLabel: 'Урамшуулал маскот',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.amber100),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _Total(
                          label: 'Нийт орлого',
                          value: earned,
                          color: AppColors.emerald700,
                          hidden: hidden,
                        ),
                      ),
                      const VerticalDivider(
                        width: 24,
                        thickness: 1,
                        color: AppColors.amber100,
                      ),
                      Expanded(
                        child: _Total(
                          label: 'Нийт зарцуулалт',
                          value: -spent,
                          color: AppColors.rose600,
                          hidden: hidden,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Equal-height tiles, whatever each title wraps to.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Shortcut(
                  asset: Stickers.addFriend,
                  tint: AppColors.orange50,
                  title: 'Найз урих',
                  subtitle: '5,000 оноо',
                  subtitleColor: AppColors.emerald600,
                  onTap: () => onOpen(AppRoutes.inviteFriends),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Shortcut(
                  asset: Stickers.goal,
                  tint: AppColors.amber50,
                  title: 'Урамшуулал авах',
                  subtitle: 'Даалгаврууд',
                  subtitleColor: AppColors.sky600,
                  onTap: () => onOpen(AppRoutes.rewardOpportunities),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionHeader(
          title: 'ГҮЙЛГЭЭНИЙ ЖАГСААЛТ',
          mascot: Stickers.report,
          padding: EdgeInsets.fromLTRB(4, 0, 4, 10),
        ),
        for (final (i, item) in items.indexed) ...[
          ListItemEntrance(
            id: item,
            index: i,
            always: true,
            delay: AppTabView.incomingDelay,
            child: TransactionTile(item: item),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// One of the card's two totals: a small label over a signed amount.
class _Total extends StatelessWidget {
  const _Total({
    required this.label,
    required this.value,
    required this.color,
    required this.hidden,
  });

  final String label;
  final int value;
  final Color color;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          size: 11,
          weight: FontWeight.w500,
          color: AppColors.slate500,
        ),
        const SizedBox(height: 2),
        HideableBalance(
          hidden: hidden,
          balance: BalanceText(
            value,
            size: 15,
            sign: value > 0,
            weight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.asset,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    required this.onTap,
  });

  final String asset;
  final Color tint;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: MascotImage(
                  asset: asset,
                  size: 42,
                  background: tint,
                  semanticLabel: title,
                ),
              ),
              const Spacer(),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.slate50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.slate500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(title, size: 13, weight: FontWeight.w700),
          const SizedBox(height: 2),
          AppText(
            subtitle,
            size: 11,
            weight: FontWeight.w700,
            color: subtitleColor,
          ),
        ],
      ),
    );
  }
}
