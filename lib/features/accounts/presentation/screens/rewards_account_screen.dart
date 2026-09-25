import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import 'coin_account_screen.dart';
import '../widgets/rewards_pane.dart';

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
        child: AdaptiveListView(
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
                  : RewardsPane(
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
