import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/card_art.dart';

/// Home's Карт tab: the active card, the one waiting on the parent, and a
/// row to order a new one, as text rows without icon tiles.
class CardsPane extends StatelessWidget {
  const CardsPane({super.key, required this.onOpen});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListItemEntrance(
          id: #mainCard,
          index: 0,
          always: true,
          delay: AppTabView.incomingDelay,
          child: AppCard(
            shadow: false,
            image: cardTabArt('active'),
            onTap: () => onOpen(AppRoutes.card),
            child: Row(
              children: [
                const Expanded(
                  child: _TwoLine(title: 'Үндсэн карт', subtitle: '•••• 5521'),
                ),
                const StatusBadge(label: 'Идэвхтэй', tone: BadgeTone.emerald),
                const SizedBox(width: 4),
                LineIcon(
                  LineGlyph.chevronRight,
                  size: 18,
                  color: AppColors.slate500,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        ListItemEntrance(
          id: #pendingCard,
          index: 1,
          always: true,
          delay: AppTabView.incomingDelay,
          child: AppCard(
            shadow: false,
            image: cardTabArt('pending'),
            onTap: () => onOpen(AppRoutes.cardOrder),
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: _TwoLine(
                        title: 'Шинэ карт',
                        subtitle: '•••• 8820',
                      ),
                    ),
                    StatusBadge(label: 'Хүлээгдэж буй', tone: BadgeTone.amber),
                  ],
                ),
                Divider(height: 24, color: AppColors.line),
                Row(
                  children: [
                    LineIcon(
                      LineGlyph.clock,
                      size: 16,
                      color: AppColors.amber600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: AppText(
                        'Эцэг эхийн зөвшөөрөл хүлээж байна',
                        size: 12,
                        color: AppColors.slate500,
                      ),
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
          child: Semantics(
            button: true,
            label: 'Карт захиалах',
            excludeSemantics: true,
            child: AppCard(
              shadow: false,
              image: cardTabArt('order'),
              onTap: () => onOpen(AppRoutes.cardOrder),
              child: Row(
                children: [
                  const Expanded(
                    child: _TwoLine(
                      title: 'Карт захиалах',
                      subtitle: 'Өөрийн загвараар',
                    ),
                  ),
                  LineIcon(
                    LineGlyph.chevronRight,
                    size: 18,
                    color: AppColors.slate500,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
        AppText(
          title,
          size: 14,
          weight: FontWeight.w600,
          color: AppColors.slate900,
        ),
        const SizedBox(height: 2),
        AppText(subtitle, size: 12, color: AppColors.slate500),
      ],
    );
  }
}
