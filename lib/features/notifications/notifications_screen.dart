import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';

enum NotificationKind { transaction, request, goal }

class _Notification {
  _Notification({
    required this.kind,
    required this.time,
    required this.title,
    required this.body,
    required this.asset,
    required this.tint,
    this.today = true,
    this.unread = false,
    this.progress,
    this.action,
    this.route,
  });

  final NotificationKind kind;
  final String time;
  final String title;
  final InlineSpan body;
  final String asset;
  final Color tint;
  final bool today;
  bool unread;
  final double? progress;
  final (String, String)? action;

  /// Screen opened when the card is tapped.
  final String? route;
}

/// "Мэдэгдэл": notification feed with category filters.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final _items = [
    _Notification(
      route: AppRoutes.home,
      kind: NotificationKind.transaction,
      time: '10 минутын өмнө',
      title: 'Ээж ₮ 20,000 халаасны мөнгө шилжүүллээ! 🎉',
      body: const TextSpan(text: '«Сайн сураарай миний хүү!»'),
      asset: Mascots.foxPhone,
      tint: AppColors.amber50,
      unread: true,
      action: ('Үлдэгдэл шалгах →', AppRoutes.home),
    ),
    _Notification(
      route: AppRoutes.requestList,
      kind: NotificationKind.request,
      time: '2 цагийн өмнө',
      title: 'Гэрийн даалгавар баталгаажлаа ✔',
      body: TextSpan(
        text: 'Аав таны хүсэлтийг зөвшөөрч ',
        children: [
          TextSpan(text: '₮ 10,000', style: _bold),
          const TextSpan(text: ' шилжүүлэв.'),
        ],
      ),
      asset: Mascots.bunnyBattery,
      tint: AppColors.emerald50,
      unread: true,
    ),
    _Notification(
      route: AppRoutes.savingsAccount,
      kind: NotificationKind.goal,
      time: '4 цагийн өмнө',
      title: 'PlayStation 5 Pro зорилго 50%-д хүрлээ! 🎮✨',
      body: const TextSpan(
        text: 'Та зорилгынхоо талыг хуримтлуулж чадлаа, мундаг байна!',
      ),
      asset: Mascots.puppyGamepad,
      tint: const Color(0xFFEFF6FF),
      unread: true,
      progress: 0.5,
    ),
    _Notification(
      route: AppRoutes.coinAccount,
      kind: NotificationKind.transaction,
      time: 'Өчигдөр, 16:45',
      title: 'CU дэлгүүрт карт уншуулав 🍦',
      body: TextSpan(
        text: '₮ 5,600 зарцууллаа. Үлдэгдэл: ',
        children: [TextSpan(text: '₮ 567,930', style: _bold)],
      ),
      asset: Mascots.bearCard,
      tint: AppColors.slate50,
      today: false,
    ),
    _Notification(
      route: AppRoutes.profile,
      kind: NotificationKind.request,
      time: 'Өчигдөр, 09:12',
      title: 'Өдрийн лимит шинэчлэгдлээ 🛡️',
      body: const TextSpan(
        text: 'Аав өдрийн зарцуулалтын лимитийг ₮ 100,000 болгон тохирууллаа.',
      ),
      asset: Mascots.penguinChecklist,
      tint: AppColors.indigo50,
      today: false,
    ),
    _Notification(
      route: AppRoutes.rewardsAccount,
      kind: NotificationKind.goal,
      time: '2 өдрийн өмнө',
      title: 'Шинэ тэмдэг нээгдлээ: "Тэргүүн хэмнэгч" 🏅',
      body: TextSpan(
        text: 'Баяр хүргэе! Танд ',
        children: [
          TextSpan(text: '+50 XP оноо', style: _bold),
          const TextSpan(text: ' амжилттай нэмэгдлээ.'),
        ],
      ),
      asset: Mascots.bearStar,
      tint: AppColors.rose50,
      today: false,
    ),
  ];

  static final _bold = comfortaa(
    size: 11,
    weight: FontWeight.w700,
    color: AppColors.slate700,
  );

  int _filter = 0;

  Iterable<_Notification> get _visible => switch (_filter) {
    1 => _items.where((n) => n.kind == NotificationKind.transaction),
    2 => _items.where((n) => n.kind == NotificationKind.request),
    3 => _items.where((n) => n.kind == NotificationKind.goal),
    _ => _items,
  };

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6FAFF);
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
            : CircleIconButton(
                icon: Icons.done_all_rounded,
                label: 'Бүгдийг унших',
                color: AppColors.sky500,
                onPressed: () => setState(() {
                  for (final n in _items) {
                    n.unread = false;
                  }
                }),
              ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final (i, l) in [
                  'Бүгд (${_items.length})',
                  'Гүйлгээ',
                  'Хүсэлт & Батлах',
                  'Зорилго & Тэмдэг',
                ].indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChipPill(
                      label: l,
                      selected: _filter == i,
                      onTap: () => setState(() => _filter = i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (today.isNotEmpty) ...[
            _GroupHeader(
              label: 'ӨНӨӨДӨР',
              badge: unread > 0 ? '$unread шинэ' : null,
            ),
            for (final n in today) _tile(n),
          ],
          if (earlier.isNotEmpty) ...[
            const SizedBox(height: 8),
            const _GroupHeader(label: 'ӨЧИГДӨР'),
            for (final n in earlier) _tile(n),
          ],
          if (today.isEmpty && earlier.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: AppText(
                'Мэдэгдэл алга',
                size: 13,
                color: AppColors.slate400,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  void _open(_Notification n) {
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

  Widget _tile(_Notification n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        radius: 24,
        padding: const EdgeInsets.all(16),
        borderColor: n.unread ? AppColors.sky200 : AppColors.slate100,
        onTap: () => _open(n),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MascotTile(asset: n.asset, background: n.tint, label: n.title),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    n.time,
                    size: 10,
                    weight: FontWeight.w500,
                    color: AppColors.slate400,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    n.title,
                    size: 12,
                    weight: FontWeight.w700,
                    height: 1.4,
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    n.body,
                    style: comfortaa(
                      size: 11,
                      weight: FontWeight.w500,
                      color: AppColors.slate500,
                      height: 1.5,
                    ),
                  ),
                  if (n.progress != null) ...[
                    const SizedBox(height: 10),
                    ProgressTrack(value: n.progress!),
                  ],
                  if (n.action != null) ...[
                    const SizedBox(height: 10),
                    SoftButton(
                      label: n.action!.$1,
                      height: 28,
                      onPressed: () => context.go(n.action!.$2),
                    ),
                  ],
                ],
              ),
            ),
            if (n.unread)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(left: 6),
                decoration: const BoxDecoration(
                  color: AppColors.sky500,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label, this.badge});

  final String label;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              label,
              size: 12,
              weight: FontWeight.w700,
              color: AppColors.slate400,
              letterSpacing: 0.8,
            ),
          ),
          if (badge != null) StatusBadge(label: badge!),
        ],
      ),
    );
  }
}
