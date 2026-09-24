import 'package:flutter/material.dart';

import '../../../../app/avatar.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/ui.dart';

/// Paid and still-open totals for the range, on Home's white card with the
/// companion's report sticker.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.paid,
    required this.paidCount,
    required this.open,
    required this.openCount,
  });

  final int paid;
  final int paidCount;
  final int open;
  final int openCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.sky100.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Нийт төлөгдсөн',
                      size: 12,
                      weight: FontWeight.w500,
                      color: AppColors.slate400,
                    ),
                    const SizedBox(height: 2),
                    BalanceText(
                      paid,
                      animateFrom: 0,
                      size: 30,
                      weight: FontWeight.w600,
                      currencyWeight: FontWeight.w600,
                      currencyColor: AppColors.slate700,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      '$paidCount нэхэмжлэх төлөгдсөн',
                      size: 11,
                      weight: FontWeight.w600,
                      color: AppColors.emerald600,
                    ),
                  ],
                ),
              ),
              MascotImage(
                asset: Stickers.report,
                size: 90,
                background: Colors.white,
                semanticLabel: 'Хуулга харж буй маскот',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.amber50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: AppColors.amber500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    openCount == 0
                        ? 'Хүлээгдэж буй нэхэмжлэх алга'
                        : '$openCount нэхэмжлэх хүлээгдэж байна',
                    size: 12,
                    weight: FontWeight.w600,
                    color: AppColors.slate700,
                  ),
                ),
                if (openCount > 0)
                  BalanceText(
                    open,
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.amber600,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
