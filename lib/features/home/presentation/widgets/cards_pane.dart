import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import 'dashed_action.dart';

class CardsPane extends StatelessWidget {
  const CardsPane({super.key, required this.onOpen});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListItemEntrance(
          id: #juniorCard,
          index: 0,
          always: true,
          delay: AppTabView.incomingDelay,
          child: AppCard(
            radius: 18,
            padding: const EdgeInsets.all(16),
            onTap: () => onOpen(AppRoutes.card),
            child: Row(
              children: [
                _IconTile(
                  icon: Icons.credit_card_rounded,
                  background: AppColors.sky100,
                  color: AppColors.sky600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TwoLine(title: 'Junior Card', subtitle: '•••• 5521'),
                ),
                const StatusBadge(label: 'Идэвхтэй', tone: BadgeTone.emerald),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.slate400,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        ListItemEntrance(
          id: #neonCard,
          index: 1,
          always: true,
          delay: AppTabView.incomingDelay,
          child: AppCard(
            radius: 18,
            padding: const EdgeInsets.all(16),
            onTap: () => onOpen(AppRoutes.cardOrder),
            child: Column(
              children: [
                Row(
                  children: [
                    _IconTile(
                      icon: Icons.credit_card_rounded,
                      background: AppColors.amber500.withValues(alpha: 0.1),
                      color: AppColors.amber500,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TwoLine(
                        title: 'Custom Neon Card',
                        subtitle: '•••• 8820',
                      ),
                    ),
                    const StatusBadge(
                      label: 'Хүлээгдэж буй',
                      tone: BadgeTone.amber,
                      icon: Icons.schedule_rounded,
                    ),
                  ],
                ),
                const Divider(height: 20, color: AppColors.slate100),
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.amber500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: AppText(
                        'Эцэг эхийн зөвшөөрөл хүлээж байна',
                        size: 11,
                        color: AppColors.slate400,
                      ),
                    ),
                    AppText(
                      'Дэлгэрэнгүй',
                      size: 11,
                      weight: FontWeight.w700,
                      color: AppColors.sky600,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        ListItemEntrance(
          id: #orderCard,
          index: 2,
          always: true,
          delay: AppTabView.incomingDelay,
          child: DashedAction(
            icon: Icons.add_card_rounded,
            label: 'Шинэ загварын хүүхдийн карт захиалах',
            onTap: () => onOpen(AppRoutes.cardOrder),
          ),
        ),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.background,
    required this.color,
  });

  final IconData icon;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _TwoLine extends StatelessWidget {
  const _TwoLine({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(title, size: 13, weight: FontWeight.w500),
        const SizedBox(height: 2),
        AppText(subtitle, size: 11, color: AppColors.slate600),
      ],
    );
  }
}
