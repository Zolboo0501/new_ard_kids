import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/kid_profile.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/app_notification.dart';
import '../widgets/group_header.dart';
import '../widgets/notification_card.dart';

/// "Мэдэгдэл": notification feed with category filters.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final _items = [
    AppNotification(
      route: AppRoutes.home,
      kind: NotificationKind.transaction,
      topic: NotificationTopic.income,
      time: '10 минутын өмнө',
      title: 'Ээж ${formatMnt(20000)} шилжүүллээ',
      body: const TextSpan(text: 'Халаасны мөнгө · «Амжилт хүсье»'),
      unread: true,
    ),
    AppNotification(
      route: AppRoutes.requestList,
      kind: NotificationKind.request,
      topic: NotificationTopic.income,
      time: '2 цагийн өмнө',
      title: 'Хүсэлт зөвшөөрөгдлөө',
      body: TextSpan(
        text: 'Аав таны хүсэлтийг зөвшөөрч ',
        children: [
          TextSpan(text: formatMnt(10000), style: _bold),
          const TextSpan(text: ' шилжүүллээ.'),
        ],
      ),
      unread: true,
    ),
    AppNotification(
      route: AppRoutes.savingsAccount,
      kind: NotificationKind.goal,
      topic: NotificationTopic.goal,
      time: '4 цагийн өмнө',
      title: 'PlayStation 5 Pro: зорилгын 50% хуримтлагдлаа',
      body: const TextSpan(text: 'Зорилгынхоо талыг хуримтлууллаа.'),
      unread: true,
      progress: 0.5,
    ),
    AppNotification(
      route: AppRoutes.coinAccount,
      kind: NotificationKind.transaction,
      topic: NotificationTopic.spending,
      time: 'Өчигдөр, 16:45',
      title: 'CU дэлгүүрт картаар төллөө',
      body: TextSpan(
        text: '${formatMnt(5600)} зарцууллаа. Үлдэгдэл: ',
        children: [TextSpan(text: formatMnt(Balances.main), style: _bold)],
      ),
      today: false,
    ),
    AppNotification(
      route: AppRoutes.profile,
      kind: NotificationKind.request,
      topic: NotificationTopic.security,
      time: 'Өчигдөр, 09:12',
      title: 'Өдрийн хязгаар шинэчлэгдлээ',
      body: TextSpan(
        text:
            'Аав өдрийн зарцуулалтын хязгаарыг '
            '${formatMnt(Limits.dailyTransfer)} болгож тохирууллаа.',
      ),
      today: false,
    ),
    AppNotification(
      route: AppRoutes.rewardsAccount,
      kind: NotificationKind.goal,
      topic: NotificationTopic.reward,
      time: '2 өдрийн өмнө',
      title: 'Шинэ тэмдэг: «Тэргүүн хэмнэгч»',
      body: const TextSpan(text: 'Урамшууллын данс руу нэмэгдлээ.'),
      today: false,
    ),
  ];

  static final _bold = inter(
    size: 13,
    weight: FontWeight.w600,
    color: AppColors.slate900,
  );

  int _filter = 0;

  Iterable<AppNotification> get _visible => switch (_filter) {
    1 => _items.where((n) => n.kind == NotificationKind.transaction),
    2 => _items.where((n) => n.kind == NotificationKind.request),
    3 => _items.where((n) => n.kind == NotificationKind.goal),
    _ => _items,
  };

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface;
    final unread = _items.where((n) => n.unread).length;
    final today = _visible.where((n) => n.today).toList();
    final earlier = _visible.where((n) => !n.today).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(
        title: 'Мэдэгдэл',
        background: bg,
        trailing: unread == 0
            ? null
            : Semantics(
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: withHaptic(
                    () => setState(() {
                      for (final n in _items) {
                        n.unread = false;
                      }
                    }),
                  ),
                  // The header keeps 44pt for its trailing action, so this
                  // is an icon, named for screen readers.
                  child: SizedBox.square(
                    dimension: 44,
                    child: Center(
                      child: LineIcon(
                        LineGlyph.checkCircle,
                        size: 24,
                        color: AppColors.sky600,
                        semanticLabel: 'Бүгдийг уншсан',
                      ),
                    ),
                  ),
                ),
              ),
      ),
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final (i, l) in [
                    'Бүгд',
                    'Гүйлгээ',
                    'Хүсэлт',
                    'Зорилго, шагнал',
                  ].indexed)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Center(
                        child: FilterChipPill(
                          label: l,
                          selected: _filter == i,
                          onTap: () => setState(() => _filter = i),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (today.isNotEmpty) ...[
              GroupHeader(
                label: 'Өнөөдөр',
                badge: unread > 0 ? '$unread шинэ' : null,
              ),
              for (final (i, n) in today.indexed)
                ListItemEntrance(
                  id: n,
                  index: i,
                  group: _filter,
                  child: NotificationCard(
                    notification: n,
                    onTap: () => _open(n),
                  ),
                ),
            ],
            if (earlier.isNotEmpty) ...[
              const SizedBox(height: 14),
              const GroupHeader(label: 'Өмнө'),
              for (final (i, n) in earlier.indexed)
                ListItemEntrance(
                  id: n,
                  index: today.length + i,
                  group: _filter,
                  child: NotificationCard(
                    notification: n,
                    onTap: () => _open(n),
                  ),
                ),
            ],
            if (today.isEmpty && earlier.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: AppText(
                  'Мэдэгдэл алга',
                  size: 14,
                  color: AppColors.slate500,
                  textAlign: TextAlign.center,
                ),
              ),
          ]),
        ),
      ),
    );
  }

  void _open(AppNotification n) {
    setState(() => n.unread = false);
    final route = n.route;
    if (route == null) return;
    // Tabs of the signed-in shell are switched with `go`; other screens stack.
    if (route == AppRoutes.home || route == AppRoutes.profile) {
      context.go(route);
    } else {
      context.push(route);
    }
  }
}
