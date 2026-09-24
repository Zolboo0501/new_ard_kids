import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/avatar.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/money_request.dart';
import '../widgets/filter_tab.dart';
import '../widgets/request_card.dart';
import '../widgets/request_list_summary.dart';

/// "Мөнгө хүсэх - Хүсэлтийн жагсаалт": history of money requests.
class RequestListScreen extends StatefulWidget {
  const RequestListScreen({super.key});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  final _requests = [
    MoneyRequest(
      from: 'Ээж',
      when: 'Өнөөдөр, 14:20',
      title: 'Зургийн дэвтэр, усан будаг, багс авах',
      amount: 20000,
      sticker: () => Stickers.art,
      status: RequestStatus.pending,
      tag: 'Хичээл',
    ),
    MoneyRequest(
      from: 'Аав',
      when: 'Өчигдөр, 18:45',
      title: 'PlayStation тоглоом, эрхийн карт',
      amount: 25000,
      sticker: () => Stickers.games,
      status: RequestStatus.approved,
      reply: 'Аав: "Хичээлээ сайн хийгээрэй миний хүү!"',
    ),
    MoneyRequest(
      from: 'Ээж',
      when: '2026.09.09',
      title: 'Өдрийн хоол, амттан, сүү',
      amount: 10000,
      sticker: () => Stickers.snack,
      status: RequestStatus.approved,
    ),
    MoneyRequest(
      from: 'Аав',
      when: '2026.09.05',
      title: 'Шинэ лего тоглоом',
      amount: 40000,
      sticker: () => Stickers.gift,
      status: RequestStatus.declined,
      reason: 'Хязгаар хүрсэн',
    ),
  ];

  int _filter = 0;

  List<MoneyRequest> get _visible => switch (_filter) {
    1 => _requests.where((r) => r.status == RequestStatus.pending).toList(),
    2 => _requests.where((r) => r.status == RequestStatus.approved).toList(),
    3 => _requests.where((r) => r.status == RequestStatus.declined).toList(),
    _ => _requests,
  };

  int _count(RequestStatus s) => _requests.where((r) => r.status == s).length;

  @override
  Widget build(BuildContext context) {
    final total = _requests.fold(0, (a, r) => a + r.amount);
    return Scaffold(
      backgroundColor: AppColors.dsSurface,
      appBar: const SubPageHeader(
        title: 'Хүсэлтийн жагсаалт',
        background: AppColors.dsSurface,
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
                      MascotImage(
                        asset: Stickers.contacts,
                        size: 80,
                        background: Colors.white,
                        semanticLabel: 'Хүсэлтийн жагсаалттай маскот',
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.slate100),
                  Row(
                    children: [
                      RequestListSummary(
                        label: 'Нийт хүссэн',
                        value: total,
                        background: AppColors.dsSurfaceContainerLow,
                        color: AppColors.sky600,
                      ),
                      const SizedBox(width: 8),
                      RequestListSummary(
                        label: 'Зөвшөөрсөн',
                        value: '${_count(RequestStatus.approved)} хүсэлт',
                        background: AppColors.emerald50,
                        color: const Color(0xFF006C49),
                        dot: AppColors.emerald500,
                      ),
                      const SizedBox(width: 8),
                      RequestListSummary(
                        label: 'Хүлээгдэж буй',
                        value: '${_count(RequestStatus.pending)} хүсэлт',
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
                    (
                      'Хүлээгдэж буй',
                      _count(RequestStatus.pending),
                      BadgeTone.amber,
                    ),
                    (
                      'Зөвшөөрсөн',
                      _count(RequestStatus.approved),
                      BadgeTone.emerald,
                    ),
                    (
                      'Татгалзсан',
                      _count(RequestStatus.declined),
                      BadgeTone.rose,
                    ),
                  ].indexed)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterTab(
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
            for (final (i, r) in _visible.indexed) ...[
              ListItemEntrance(
                id: r,
                index: i,
                group: _filter,
                child: RequestCard(
                  request: r,
                  onNudge: () => showAppSnack(
                    context,
                    '${r.fromDative} сануулга илгээлээ',
                    mascot: Stickers.notification,
                  ),
                  onCancel: () => setState(() => _requests.remove(r)),
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 6),
            PrimaryButton(
              label: 'Шинэ хүсэлт илгээх',
              leadingIcon: Icons.add_rounded,
              onPressed: () => context.pushReplacement(AppRoutes.requestMoney),
            ),
          ]),
        ),
      ),
    );
  }
}
