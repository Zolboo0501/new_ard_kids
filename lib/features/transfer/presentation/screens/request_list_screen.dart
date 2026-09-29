import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
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
    const MoneyRequest(
      from: 'Ээж',
      when: 'Өнөөдөр, 14:20',
      title: 'Сургуулийн аялал',
      amount: 20000,
      glyph: LineGlyph.bus,
      status: RequestStatus.pending,
    ),
    const MoneyRequest(
      from: 'Аав',
      when: 'Өчигдөр, 18:45',
      title: 'Чихэвч',
      amount: 45000,
      glyph: LineGlyph.bag,
      status: RequestStatus.approved,
      reply: 'Аав: "Хадгалж хэрэглээрэй"',
    ),
    const MoneyRequest(
      from: 'Ээж',
      when: '2026.09.09',
      title: 'Долоо хоногийн өдрийн хоол',
      amount: 10000,
      glyph: LineGlyph.food,
      status: RequestStatus.approved,
    ),
    const MoneyRequest(
      from: 'Аав',
      when: '2026.09.05',
      title: 'Шинэ пүүз',
      amount: 80000,
      glyph: LineGlyph.shirt,
      status: RequestStatus.declined,
      reason: 'Энэ сарын төсөв хүрэхгүй',
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
      appBar: SubPageHeader(
        title: 'Хүсэлтийн жагсаалт',
        background: AppColors.dsSurface,
      ),
      body: Column(
        children: [
          Expanded(
            child: EntranceScope(
              child: AdaptiveListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: EntranceItem.list([
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          RequestListSummary(
                            label: 'Нийт хүссэн',
                            value: total,
                          ),
                          VerticalDivider(width: 24, color: AppColors.line),
                          RequestListSummary(
                            label: 'Зөвшөөрсөн',
                            value: '${_count(RequestStatus.approved)}',
                          ),
                          VerticalDivider(width: 24, color: AppColors.line),
                          RequestListSummary(
                            label: 'Хүлээгдэж буй',
                            value: '${_count(RequestStatus.pending)}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final (i, f) in [
                          ('Бүгд', null),
                          ('Хүлээгдэж буй', _count(RequestStatus.pending)),
                          ('Зөвшөөрсөн', _count(RequestStatus.approved)),
                          ('Татгалзсан', _count(RequestStatus.declined)),
                        ].indexed)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterTab(
                              label: f.$1,
                              count: f.$2,
                              selected: _filter == i,
                              onTap: () => setState(() => _filter = i),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_visible.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: AppText(
                        'Энд хүсэлт алга',
                        size: 13,
                        color: AppColors.slate500,
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
                        ),
                        onCancel: () => setState(() => _requests.remove(r)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ]),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.dsSurface,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            child: AdaptiveCenter(
              child: PrimaryButton(
                label: 'Шинэ хүсэлт',
                onPressed: () =>
                    context.pushReplacement(AppRoutes.requestMoney),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
