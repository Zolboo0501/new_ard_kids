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

  static const _items = [
    TxItem(
      title: 'Гэрийн даалгавраа онц хийсэн',
      subtitle: 'Ааваас олгосон',
      when: 'Өнөөдөр',
      amount: 10000,
      asset: Mascots.owlBook,
      tint: Colors.white,
    ),
    TxItem(
      title: 'Хадгаламжийн зорилгодоо хүрсэн',
      subtitle: 'Ээжийн нэмэгдэл',
      when: 'Өчигдөр',
      amount: 15000,
      asset: Mascots.bearConfetti,
      tint: Colors.white,
      amountColor: AppColors.sky600,
    ),
    TxItem(
      title: 'Найзаа урьж бүртгүүлсэн',
      subtitle: 'Урамшуулал',
      when: '05.12',
      amount: 5000,
      asset: Mascots.foxWave,
      tint: Colors.white,
      badge: 'Амжилттай',
      badgeTone: BadgeTone.amber,
    ),
    TxItem(
      title: 'Ном унших сарын челленж',
      subtitle: 'Сургуулийн даалгавар',
      when: '05.10',
      amount: 10000,
      asset: Mascots.owlMedal,
      tint: Colors.white,
      badge: 'Биелүүлсэн',
    ),
    TxItem(
      title: 'Интерном эрхийн бичиг авсан',
      subtitle: 'Бэлэг худалдан авалт',
      when: '05.08',
      amount: -20000,
      asset: Mascots.bearBooks,
      tint: Colors.white,
      badge: 'Зарцуулсан',
      badgeTone: BadgeTone.slate,
      amountColor: AppColors.slate700,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, AppColors.amber50],
            ),
            border: Border.all(color: AppColors.amber100),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                right: -12,
                bottom: -16,
                child: MascotImage(
                  asset: Mascots.redPandaTrophy,
                  size: 120,
                  background: Color(0xFFFFFDF5),
                  semanticLabel: 'Урамшуулал маскот',
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Нийт үлдэгдэл',
                    size: 12,
                    weight: FontWeight.w500,
                    color: AppColors.slate500,
                  ),
                  HideableBalance(
                    hidden: hidden,
                    balance: const BalanceText(
                      35000,
                      animateFrom: 0,
                      size: 30,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _Shortcut(
                asset: Mascots.foxWave,
                title: 'Найз урих',
                subtitle: '5,000 оноо',
                subtitleColor: AppColors.emerald600,
                onTap: () => onOpen(AppRoutes.inviteFriends),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Shortcut(
                asset: Mascots.redPandaTrophy,
                title: 'Урамшуулал авах',
                subtitle: 'Даалгаврууд',
                subtitleColor: AppColors.sky600,
                onTap: () => onOpen(AppRoutes.rewardOpportunities),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SectionHeader(
          title: 'Гүйлгээний жагсаалт',
          icon: Icons.receipt_long_outlined,
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
        ),
        for (final (i, item) in _items.indexed) ...[
          ListItemEntrance(
            id: item,
            index: i,
            always: true,
            delay: AppTabView.incomingDelay,
            child: TransactionTile(item: item, whenBelow: true),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    required this.onTap,
  });

  final String asset;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          MascotImage(
            asset: asset,
            size: 40,
            background: Colors.white,
            semanticLabel: title,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, size: 12, weight: FontWeight.w700),
                AppText(
                  subtitle,
                  size: 10,
                  weight: FontWeight.w700,
                  color: subtitleColor,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.slate400,
          ),
        ],
      ),
    );
  }
}
