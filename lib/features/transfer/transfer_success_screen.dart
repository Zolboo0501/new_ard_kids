import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

/// Result of a completed transfer shown on the receipt screen.
class TransferReceipt {
  const TransferReceipt({
    required this.amount,
    required this.recipient,
    required this.bank,
    required this.destination,
    required this.note,
    required this.balanceAfter,
    required this.time,
  });

  final int amount;
  final String recipient;
  final String bank;
  final String destination;
  final String note;
  final int balanceAfter;
  final DateTime time;
}

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
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          AppCard(
            radius: 28,
            padding: const EdgeInsets.all(20),
            borderColor: AppColors.slate100,
            child: Column(
              children: [
                const MascotImage(
                  asset: Mascots.bearStar,
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
                Text(
                  'Гүйлгээ амжилттай!',
                  style: comfortaa(size: 18, weight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '₮',
                        style: moneyStyle(
                          size: 24,
                          weight: FontWeight.w600,
                          color: AppColors.sky400,
                        ),
                      ),
                      TextSpan(
                        text: formatMnt(r.amount).substring(1),
                        style: moneyStyle(size: 34, color: AppColors.sky500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _date(r.time),
                  style: comfortaa(size: 12, color: AppColors.slate400),
                ),
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
                _Row(
                  label: 'Хүлээн авагч',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            r.recipient,
                            style: comfortaa(size: 13, weight: FontWeight.w700),
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
                      Text(
                        '${r.bank} • 5049****',
                        style: comfortaa(size: 11, color: AppColors.slate400),
                      ),
                    ],
                  ),
                ),
                _Row(
                  label: 'Шилжүүлсэн',
                  divider: true,
                  child: Text(
                    r.destination,
                    textAlign: TextAlign.right,
                    style: comfortaa(
                      size: 12,
                      weight: FontWeight.w600,
                      color: AppColors.slate700,
                    ),
                  ),
                ),
                _Row(
                  label: 'Гүйлгээний утга',
                  divider: true,
                  child: Text(
                    r.note,
                    style: comfortaa(size: 13, weight: FontWeight.w600),
                  ),
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
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 18,
                          color: AppColors.sky600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Боломжит үлдэгдэл',
                          style: comfortaa(
                            size: 12,
                            weight: FontWeight.w600,
                            color: AppColors.slate600,
                          ),
                        ),
                      ),
                      Text(
                        formatMnt(r.balanceAfter, space: true),
                        style: moneyStyle(size: 14),
                      ),
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
          PrimaryButton(
            label: 'Баримт хуваалцах',
            leadingIcon: Icons.ios_share_rounded,
            onPressed: () =>
                showAppSnack(context, 'Баримт хуваалцах холбоос бэлэн'),
          ),
          const SizedBox(height: 12),
          SoftButton(
            label: 'Нүүр хуудас руу буцах',
            height: 52,
            background: Colors.white,
            foreground: AppColors.slate700,
            border: AppColors.slate200,
            onPressed: () => _home(context),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.child, this.divider = false});

  final String label;
  final Widget child;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: divider ? 12 : 0, bottom: 12),
      decoration: divider
          ? const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.slate50)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: comfortaa(
              size: 13,
              weight: FontWeight.w500,
              color: AppColors.slate400,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: child),
          ),
        ],
      ),
    );
  }
}
