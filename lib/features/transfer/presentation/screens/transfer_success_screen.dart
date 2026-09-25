import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/avatar.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/transfer_receipt.dart';
import '../widgets/transfer_success_row.dart';

/// "Гүйлгээ амжилттай" receipt.
class TransferSuccessScreen extends StatelessWidget {
  const TransferSuccessScreen({super.key, this.receipt});

  final TransferReceipt? receipt;

  static final _sample = TransferReceipt(
    amount: 15000,
    recipient: 'Б. Сүхбат',
    bank: 'Хаан банк',
    destination: '9911 2345 / 5049 8219 02',
    note: 'Ном авсан',
    balanceAfter: 552930,
    time: DateTime(2026, 9, 11, 14, 32),
  );

  static String _date(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year} оны ${two(t.month)} сарын ${two(t.day)}, '
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
    const bg = Color(0xFFF4F9FD);
    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(
        title: 'Гүйлгээний баримт',
        background: bg,
        showBack: false,
        trailing: CircleIconButton(
          icon: Icons.download_rounded,
          label: 'Баримт татах',
          onPressed: () => showAppSnack(context, 'Баримт хадгалагдлаа'),
        ),
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
            AppCard(
              radius: 28,
              padding: const EdgeInsets.all(20),
              borderColor: AppColors.slate100,
              child: Column(
                children: [
                  MascotImage(
                    asset: Stickers.success,
                    size: 128,
                    background: Colors.white,
                    semanticLabel: 'Амжилттай гүйлгээний баяр хөөр',
                  ),
                  const SizedBox(height: 8),
                  const StatusBadge(
                    label: 'Хүлээн авагчийн дансанд орсон ✓',
                    tone: BadgeTone.emerald,
                    dot: true,
                  ),
                  const SizedBox(height: 10),
                  AppText(
                    'Гүйлгээ амжилттай!',
                    size: 18,
                    weight: FontWeight.w700,
                  ),
                  const SizedBox(height: 4),
                  BalanceText(
                    r.amount,
                    size: 34,
                    color: AppColors.sky500,
                    weight: FontWeight.w600,
                    currencyWeight: FontWeight.w600,
                    currencyColor: AppColors.sky400,
                  ),
                  const SizedBox(height: 4),
                  AppText(_date(r.time), size: 12, color: AppColors.slate400),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              radius: 28,
              padding: const EdgeInsets.all(20),
              borderColor: AppColors.slate100,
              child: Column(
                children: [
                  TransferSuccessRow(
                    label: 'Хүлээн авагч',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              r.recipient,
                              size: 13,
                              weight: FontWeight.w700,
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppColors.emerald100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 11,
                                color: AppColors.emerald600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          '${r.bank} • 5049****',
                          size: 11,
                          color: AppColors.slate400,
                        ),
                      ],
                    ),
                  ),
                  TransferSuccessRow(
                    label: 'Шилжүүлсэн',
                    divider: true,
                    child: AppText(
                      r.destination,
                      size: 12,
                      weight: FontWeight.w600,
                      color: AppColors.slate700,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  TransferSuccessRow(
                    label: 'Гүйлгээний утга',
                    divider: true,
                    child: AppText(r.note, size: 13, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.sky50.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 18,
                            color: AppColors.sky600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppText(
                            'Боломжит үлдэгдэл',
                            size: 12,
                            weight: FontWeight.w600,
                            color: AppColors.slate600,
                          ),
                        ),
                        BalanceText(r.balanceAfter, space: false, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const InfoNote(
              icon: Icons.shield_outlined,
              text:
                  'Энэ гүйлгээ нь аав ээжийн тохируулсан өдрийн ₮100,000 лимитийн хүрээнд хамгаалагдсан байна.',
            ),
            const SizedBox(height: 18),
            SoftButton(
              label: 'Нүүр хуудас руу буцах',
              height: 52,
              background: Colors.white,
              foreground: AppColors.slate700,
              border: AppColors.slate200,
              onPressed: () => _home(context),
            ),
          ]),
        ),
      ),
    );
  }
}
