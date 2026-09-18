import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';

enum _Status { pending, approved, declined }

class _Request {
  const _Request({
    required this.from,
    required this.when,
    required this.title,
    required this.amount,
    required this.asset,
    required this.status,
    this.tag,
    this.reply,
    this.reason,
  });

  final String from;
  final String when;
  final String title;
  final int amount;
  final String asset;
  final _Status status;
  final String? tag;
  final String? reply;
  final String? reason;

  /// Genitive / dative forms for the parent names used in copy.
  String get fromGenitive => from == 'Аав' ? 'Аавын' : '$fromийн';
  String get fromDative => from == 'Ээж' ? 'Ээжид' : '$fromд';
}

/// "Мөнгө хүсэх - Хүсэлтийн жагсаалт": history of money requests.
class RequestListScreen extends StatefulWidget {
  const RequestListScreen({super.key});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  final _requests = [
    const _Request(
      from: 'Ээж',
      when: 'Өнөөдөр, 14:20',
      title: 'Зургийн дэвтэр, усан будаг, багс авах',
      amount: 20000,
      asset: Mascots.catNotes,
      status: _Status.pending,
      tag: 'Хичээл',
    ),
    const _Request(
      from: 'Аав',
      when: 'Өчигдөр, 18:45',
      title: 'PlayStation тоглоом, эрхийн карт',
      amount: 25000,
      asset: Mascots.puppyGamepad,
      status: _Status.approved,
      reply: 'Аав: "Хичээлээ сайн хийгээрэй миний хүү!"',
    ),
    const _Request(
      from: 'Ээж',
      when: '2026.09.09',
      title: 'Өдрийн хоол, амттан, сүү',
      amount: 10000,
      asset: Mascots.pandaMilk,
      status: _Status.approved,
    ),
    const _Request(
      from: 'Аав',
      when: '2026.09.05',
      title: 'Шинэ лего тоглоом',
      amount: 40000,
      asset: Mascots.foxBlocks,
      status: _Status.declined,
      reason: 'Хязгаар хүрсэн',
    ),
  ];

  int _filter = 0;

  List<_Request> get _visible => switch (_filter) {
    1 => _requests.where((r) => r.status == _Status.pending).toList(),
    2 => _requests.where((r) => r.status == _Status.approved).toList(),
    3 => _requests.where((r) => r.status == _Status.declined).toList(),
    _ => _requests,
  };

  int _count(_Status s) => _requests.where((r) => r.status == s).length;

  @override
  Widget build(BuildContext context) {
    final total = _requests.fold(0, (a, r) => a + r.amount);
    return Scaffold(
      backgroundColor: AppColors.dsSurface,
      appBar: const SubPageHeader(
        title: 'Хүсэлтийн жагсаалт',
        background: AppColors.dsSurface,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          AppCard(
            radius: 24,
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.slate100,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Хүсэлтийн нэгдсэн тойм',
                            size: 14,
                            weight: FontWeight.w700,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            'Нийт шийдвэрлэгдсэн болон хүлээгдэж буй',
                            size: 11,
                            color: AppColors.dsOnSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                    const MascotImage(
                      asset: Mascots.catHeart,
                      size: 80,
                      background: Colors.white,
                      semanticLabel: 'PocketPal Cat holding heart coin',
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.slate100),
                Row(
                  children: [
                    _Summary(
                      label: 'Нийт хүссэн',
                      value: formatMnt(total, space: true),
                      background: AppColors.dsSurfaceContainerLow,
                      color: AppColors.sky600,
                    ),
                    const SizedBox(width: 8),
                    _Summary(
                      label: 'Зөвшөөрсөн',
                      value: '${_count(_Status.approved)} хүсэлт',
                      background: AppColors.emerald50,
                      color: const Color(0xFF006C49),
                      dot: AppColors.emerald500,
                    ),
                    const SizedBox(width: 8),
                    _Summary(
                      label: 'Хүлээгдэж буй',
                      value: '${_count(_Status.pending)} хүсэлт',
                      background: AppColors.amber50,
                      color: AppColors.amber700,
                      dot: AppColors.amber500,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final (i, f) in [
                  ('Бүгд', null, null),
                  ('Хүлээгдэж буй', _count(_Status.pending), BadgeTone.amber),
                  ('Зөвшөөрсөн', _count(_Status.approved), BadgeTone.emerald),
                  ('Татгалзсан', _count(_Status.declined), BadgeTone.rose),
                ].indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterTab(
                      label: f.$1,
                      count: f.$2,
                      tone: f.$3,
                      selected: _filter == i,
                      onTap: () => setState(() => _filter = i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: AppText(
                'Хүсэлт алга байна',
                size: 13,
                color: AppColors.slate400,
                textAlign: TextAlign.center,
              ),
            ),
          for (final r in _visible) ...[
            _RequestCard(
              request: r,
              onNudge: () =>
                  showAppSnack(context, '${r.fromDative} сануулга илгээлээ 🔔'),
              onCancel: () => setState(() => _requests.remove(r)),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 6),
          PrimaryButton(
            label: 'Шинэ хүсэлт илгээх',
            leadingIcon: Icons.add_rounded,
            onPressed: () => context.pushReplacement(AppRoutes.requestMoney),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.label,
    required this.value,
    required this.background,
    required this.color,
    this.dot,
  });

  final String label;
  final String value;
  final Color background;
  final Color color;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (dot != null) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: dot,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: AppText(
                    label,
                    size: 10,
                    weight: FontWeight.w600,
                    color: AppColors.dsOnSurfaceVariant,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(value, style: moneyStyle(size: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.tone,
  });

  final String label;
  final int? count;
  final BadgeTone? tone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = tone?.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.sky500 : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.slate200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (colors != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : colors.$2,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              AppText(
                label,
                size: 12,
                weight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.slate700,
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.25)
                        : colors!.$1,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: AppText(
                    '$count',
                    size: 10,
                    weight: FontWeight.w700,
                    color: selected ? Colors.white : colors!.$2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onNudge,
    required this.onCancel,
  });

  final _Request request;
  final VoidCallback onNudge;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final r = request;
    final tint = switch (r.status) {
      _Status.pending => AppColors.amber50,
      _Status.approved => AppColors.emerald50,
      _Status.declined => AppColors.rose50,
    };
    return AppCard(
      radius: 18,
      borderColor: AppColors.slate100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Opacity(
                opacity: r.status == _Status.declined ? 0.8 : 1,
                child: MascotTile(
                  asset: r.asset,
                  background: tint,
                  label: r.title,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: '${r.from}  •  ',
                        children: [
                          TextSpan(
                            text: r.when,
                            style: comfortaa(
                              size: 10,
                              color: AppColors.slate400,
                            ),
                          ),
                        ],
                      ),
                      style: comfortaa(
                        size: 11,
                        weight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      r.title,
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.dsOnSurface,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (r.tag != null) ...[
                      const SizedBox(height: 4),
                      StatusBadge(label: r.tag!, tone: BadgeTone.slate),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+${formatMnt(r.amount, space: true)}',
                style:
                    moneyStyle(
                      size: 14,
                      weight: FontWeight.w800,
                      color: switch (r.status) {
                        _Status.pending => AppColors.sky600,
                        _Status.approved => const Color(0xFF006C49),
                        _Status.declined => AppColors.slate400,
                      },
                    ).copyWith(
                      decoration: r.status == _Status.declined
                          ? TextDecoration.lineThrough
                          : null,
                    ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.slate100),
          switch (r.status) {
            _Status.pending => Column(
              children: [
                Row(
                  children: [
                    const StatusBadge(
                      label: 'Хүлээгдэж буй',
                      tone: BadgeTone.amber,
                      dot: true,
                    ),
                    const Spacer(),
                    AppText(
                      '${r.fromGenitive} зөвшөөрөл хүлээж байна',
                      size: 10,
                      color: AppColors.amber700,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SoftButton(
                        label: 'Сануулах',
                        icon: Icons.notifications_active_outlined,
                        height: 34,
                        background: AppColors.sky500,
                        foreground: Colors.white,
                        border: null,
                        onPressed: onNudge,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SoftButton(
                      label: 'Цуцлах',
                      height: 34,
                      background: AppColors.rose50,
                      foreground: AppColors.rose600,
                      border: null,
                      onPressed: onCancel,
                    ),
                  ],
                ),
              ],
            ),
            _Status.approved => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: StatusBadge(
                    label: r.reply != null
                        ? '✓ Зөвшөөрсөн • Дансанд орсон'
                        : 'Зөвшөөрсөн',
                    tone: BadgeTone.emerald,
                  ),
                ),
                if (r.reply != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dsSurfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 14,
                          color: AppColors.sky600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppText(
                            r.reply!,
                            size: 11,
                            weight: FontWeight.w500,
                            color: AppColors.dsOnSurface,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            _Status.declined => Row(
              children: [
                const StatusBadge(label: '✕ Татгалзсан', tone: BadgeTone.rose),
                const Spacer(),
                AppText(r.reason ?? '', size: 10, color: AppColors.rose600),
              ],
            ),
          },
        ],
      ),
    );
  }
}
