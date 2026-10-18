import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/avatar.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/avatar_toast.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/transfer_receipt.dart';
import '../widgets/transfer_success_row.dart';

/// "Гүйлгээ амжилттай" receipt: a calm confirmation, the amount, and the
/// details a statement would carry.
///
/// After a real transfer (a [receipt] was passed), the teen's avatar pops up
/// at the top for a moment to say what the transfer earned ([rewardPoints]).
class TransferSuccessScreen extends StatefulWidget {
  const TransferSuccessScreen({super.key, this.receipt});

  final TransferReceipt? receipt;

  @override
  State<TransferSuccessScreen> createState() => _TransferSuccessScreenState();
}

class _TransferSuccessScreenState extends State<TransferSuccessScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.receipt == null) return;
    // Once the receipt has risen into place, so the two don't move at once.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) return;
      // At the top, under the header, gone on its own.
      showRewardToast(context);
    });
  }

  TransferReceipt? get receipt => widget.receipt;

  static final _sample = TransferReceipt(
    amount: 15000,
    recipient: 'Б. Сүхбат',
    bank: 'Хаан банк',
    destination: '5049 8219 02',
    note: 'Хоол',
    balanceAfter: 552930,
    time: DateTime(2026, 9, 11, 14, 32),
  );

  static String _date(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}.${two(t.month)}.${two(t.day)}, '
        '${two(t.hour)}:${two(t.minute)}';
  }

  void _home(BuildContext context) {
    // Home is the root of the stack once signed in (`context.go`).
    while (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = receipt ?? _sample;
    final bg = AppColors.surface;
    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(
        title: 'Гүйлгээний баримт',
        background: bg,
        showBack: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: EntranceScope(
              child: AdaptiveListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: EntranceItem.list([
                  // The kid's own companion celebrates the transfer, with
                  // a small tick so it still reads as "done".
                  Center(
                    child: SizedBox(
                      width: 128,
                      height: 140,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              appAvatar.value.fullBody,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.medium,
                              excludeFromSemantics: true,
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 6,
                            child: Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.emerald500,
                                shape: BoxShape.circle,
                                border: Border.all(color: bg, width: 3),
                              ),
                              child: LineIcon(
                                LineGlyph.check,
                                size: 18,
                                stroke: 2.4,
                                color: AppColors.onBright,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    'Гүйлгээ амжилттай',
                    size: 16,
                    weight: FontWeight.w600,
                    color: AppColors.slate600,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: BalanceText(
                      r.amount,
                      size: 40,
                      color: AppColors.slate900,
                      weight: FontWeight.w600,
                      currencyWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    _date(r.time),
                    size: 13,
                    color: AppColors.slate500,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: Column(
                      children: [
                        TransferSuccessRow(
                          label: 'Хүлээн авагч',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AppText(
                                r.recipient,
                                size: 14,
                                weight: FontWeight.w600,
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 2),
                              AppText(
                                r.bank,
                                size: 12,
                                color: AppColors.slate500,
                              ),
                            ],
                          ),
                        ),
                        TransferSuccessRow(
                          label: 'Данс',
                          divider: true,
                          child: AppText(
                            r.destination,
                            size: 14,
                            weight: FontWeight.w500,
                            color: AppColors.slate900,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        TransferSuccessRow(
                          label: 'Гүйлгээний утга',
                          divider: true,
                          child: AppText(
                            r.note,
                            size: 14,
                            weight: FontWeight.w500,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        TransferSuccessRow(
                          label: 'Үлдэгдэл',
                          divider: true,
                          child: BalanceText(
                            r.balanceAfter,
                            size: 14,
                            weight: FontWeight.w600,
                            color: AppColors.slate900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            child: AdaptiveCenter(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                    label: 'Нүүр хуудас',
                    onPressed: () => _home(context),
                  ),
                  const SizedBox(height: 10),
                  SoftButton(
                    label: 'Дахин илгээх',
                    height: 48,
                    background: AppColors.slate50,
                    foreground: AppColors.slate900,
                    border: Colors.transparent,
                    onPressed: () =>
                        context.pushReplacement(AppRoutes.transferAmount),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
