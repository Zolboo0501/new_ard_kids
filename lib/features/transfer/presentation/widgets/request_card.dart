import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/money_request.dart';

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
    final tint = switch (r.status) {
      RequestStatus.pending => AppColors.amber50,
      RequestStatus.approved => AppColors.emerald50,
      RequestStatus.declined => AppColors.rose50,
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
                opacity: r.status == RequestStatus.declined ? 0.8 : 1,
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
                            style: inter(size: 10, color: AppColors.slate400),
                          ),
                        ],
                      ),
                      style: inter(
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
              BalanceText(
                r.amount,
                sign: true,
                space: false,
                size: 14,
                weight: FontWeight.w500,
                color: switch (r.status) {
                  RequestStatus.pending => AppColors.sky600,
                  RequestStatus.approved => const Color(0xFF006C49),
                  RequestStatus.declined => AppColors.slate400,
                },
                decoration: r.status == RequestStatus.declined
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.slate100),
          switch (r.status) {
            RequestStatus.pending => Column(
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
                        border: Colors.transparent,
                        onPressed: onNudge,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SoftButton(
                      label: 'Цуцлах',
                      height: 34,
                      background: AppColors.rose50,
                      foreground: AppColors.rose600,
                      border: Colors.transparent,
                      onPressed: onCancel,
                    ),
                  ],
                ),
              ],
            ),
            RequestStatus.approved => Column(
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
                        Icon(
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
            RequestStatus.declined => Row(
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
