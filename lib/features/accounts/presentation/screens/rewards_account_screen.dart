import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import 'coin_account_screen.dart';
import '../widgets/rewards_pane.dart';
import '../../../../widgets/avatar_tour.dart';
import '../../../../app/avatar.dart';

/// "Урамшууллын данс": reward points balance and history, with the coin
/// account ([CoinAccountPane]) as a second tab. [initialTab] 1 opens straight
/// on coins, which is what [AppRoutes.coinAccount] does.
class RewardsAccountScreen extends StatefulWidget {
  const RewardsAccountScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<RewardsAccountScreen> createState() => _RewardsAccountScreenState();
}

class _RewardsAccountScreenState extends State<RewardsAccountScreen>
    with AvatarTourHost {
  /// What the first-visit tour points at.
  final _tabsKey = GlobalKey();
  final _paneKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // The first visit: the avatar walks the teen through this screen.
    startAvatarTour('rewards_account', () {
      final name = appAvatar.value.name;
      return [
        AvatarTourStep(text: 'Би $name. Оноо, койноо энд цуглуулна!'),
        AvatarTourStep(
          target: _tabsKey,
          text: 'Урамшуулал ба Ард койны хооронд эндээс шилжинэ.',
        ),
        AvatarTourStep(
          target: _paneKey,
          text: 'Хэдэн оноо, койнтой болсноо, юунаас авснаа эндээс хараарай.',
        ),
      ];
    });
  }

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
            KeyedSubtree(
              key: _tabsKey,
              child: AppTabs(
                tabs: const [AppTab('Урамшуулал'), AppTab('Койн')],
                index: _tab,
                dotOnActive: true,
                style: AppTabsStyle.card,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(height: 14),
            KeyedSubtree(
              key: _paneKey,
              child: AppTabView(
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
            ),
          ]),
        ),
      ),
    );
  }
}
