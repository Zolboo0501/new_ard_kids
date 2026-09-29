import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/money_request.dart';

/// One money request: its category tile, who it went to, the amount and
/// its status, with Сануулах / Цуцлах while it is pending.
class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.request,
    required this.onNudge,
    required this.onCancel,
  });

  final MoneyRequest request;
  final VoidCallback onNudge;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final r = request;
    final declined = r.status == RequestStatus.declined;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: LineIcon(
                  r.glyph,
                  size: 22,
                  color: declined ? AppColors.slate500 : AppColors.slate800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      r.title,
                      size: 14,
                      weight: FontWeight.w600,
                      color: declined ? AppColors.slate500 : AppColors.slate900,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      '${r.from} · ${r.when}',
                      size: 12,
                      color: AppColors.slate500,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // A declined amount is muted, not struck through: a line
              // through a price reads like a discount.
              BalanceText(
                r.amount,
                size: 15,
                weight: FontWeight.w600,
                color: switch (r.status) {
                  RequestStatus.pending => AppColors.slate900,
                  RequestStatus.approved => AppColors.emerald600,
                  RequestStatus.declined => AppColors.slate400,
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          switch (r.status) {
            RequestStatus.pending => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const StatusBadge(
                      label: 'Хүлээгдэж буй',
                      tone: BadgeTone.amber,
                      dot: true,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        '${r.fromGenitive} хариуг хүлээж байна',
                        size: 12,
                        color: AppColors.slate500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SoftButton(
                        label: 'Сануулах',
                        leading: LineIcon(
                          LineGlyph.bell,
                          size: 18,
                          color: AppColors.slate900,
                        ),
                        height: 44,
                        background: AppColors.slate50,
                        foreground: AppColors.slate900,
                        border: Colors.transparent,
                        onPressed: onNudge,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SoftButton(
                        label: 'Цуцлах',
                        height: 44,
                        background: AppColors.slate50,
                        foreground: AppColors.rose600,
                        border: Colors.transparent,
                        onPressed: onCancel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            RequestStatus.approved => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(
                  label: r.reply != null
                      ? 'Зөвшөөрсөн · Дансанд орсон'
                      : 'Зөвшөөрсөн',
                  tone: BadgeTone.emerald,
                ),
                if (r.reply != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppText(
                      r.reply!,
                      size: 13,
                      color: AppColors.slate700,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            RequestStatus.declined => Row(
              children: [
                const StatusBadge(label: 'Татгалзсан', tone: BadgeTone.rose),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    r.reason ?? '',
                    size: 12,
                    color: AppColors.slate500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          },
        ],
      ),
    );
  }
}
