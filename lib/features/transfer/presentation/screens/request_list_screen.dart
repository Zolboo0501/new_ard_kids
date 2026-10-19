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
  const RequestListScreen({super.key, this.showPending = false});

  /// Opens on the Хүлээгдэж буй filter ([AppRoutes.requestListPending]).
  final bool showPending;

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  /// The shared list, so a request just sent is in it (see [MoneyRequests]).
  List<MoneyRequest> get _requests => MoneyRequests.all;

  /// Right after a request is sent the list opens on Хүлээгдэж буй, where
  /// the new one sits at the top.
  late int _filter = widget.showPending ? 1 : 0;

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
                        onCancel: () => setState(() => MoneyRequests.remove(r)),
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
                    context.pushReplacement(AppRoutes.requestAmount),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
