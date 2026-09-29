import 'package:flutter/material.dart';

import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import 'limit_row.dart';

/// The linked parent and the daily limit they set.
class ProfileParentCard extends StatelessWidget {
  const ProfileParentCard({super.key, required this.onManage});

  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    shape: BoxShape.circle,
                  ),
                  child: AppText(
                    'БС',
                    size: 15,
                    weight: FontWeight.w600,
                    color: AppColors.slate800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Ээж · Б. Саруул',
                      size: 15,
                      weight: FontWeight.w600,
                    ),
                    const SizedBox(height: 2),
                    AppText('Голомт банк', size: 13, color: AppColors.slate500),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const StatusBadge(label: 'Идэвхтэй', tone: BadgeTone.emerald),
            ],
          ),
          Divider(height: 28, color: AppColors.line),
          const LimitRow(label: 'Өдрийн хязгаар', value: Limits.dailyTransfer),
          const SizedBox(height: 8),
          LimitRow(
            label: 'Өнөөдөр үлдсэн',
            value: Limits.leftToday,
            color: AppColors.emerald600,
          ),
          const SizedBox(height: 10),
          ProgressTrack(
            value: Limits.leftToday / Limits.dailyTransfer,
            height: 6,
            color: AppColors.emerald500,
          ),
          const SizedBox(height: 14),
          SoftButton(
            label: 'Холболтыг удирдах',
            height: 44,
            background: AppColors.slate50,
            foreground: AppColors.slate900,
            border: Colors.transparent,
            onPressed: onManage,
          ),
        ],
      ),
    );
  }
}
