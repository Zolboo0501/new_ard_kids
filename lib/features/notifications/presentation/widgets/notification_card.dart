import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/app_notification.dart';

/// One notification: a glyph tile for its topic, time, title and body.
/// Unread cards carry an accent dot.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  static (LineGlyph, Color, Color) _look(NotificationTopic topic) =>
      switch (topic) {
        NotificationTopic.income => (
          LineGlyph.arrowDownLeft,
          AppColors.emerald50,
          AppColors.emerald600,
        ),
        NotificationTopic.spending => (
          LineGlyph.arrowUpRight,
          AppColors.slate50,
          AppColors.slate800,
        ),
        NotificationTopic.security => (
          LineGlyph.shield,
          AppColors.slate50,
          AppColors.slate800,
        ),
        NotificationTopic.reward => (
          LineGlyph.gift,
          AppColors.amber50,
          AppColors.amber600,
        ),
        NotificationTopic.goal => (
          LineGlyph.target,
          AppColors.sky50,
          AppColors.sky600,
        ),
        NotificationTopic.system => (
          LineGlyph.bell,
          AppColors.slate50,
          AppColors.slate800,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final (glyph, tileBg, ink) = _look(n.topic);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        child: AppCard(
          padding: const EdgeInsets.all(16),
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tileBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: LineIcon(glyph, size: 22, color: ink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                            n.title,
                            size: 15,
                            weight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        if (n.unread)
                          Semantics(
                            label: 'Уншаагүй',
                            child: Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: AppColors.sky500,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      n.body,
                      style: inter(
                        size: 13,
                        color: AppColors.slate600,
                        height: 1.45,
                      ),
                    ),
                    if (n.progress != null) ...[
                      const SizedBox(height: 10),
                      ProgressTrack(value: n.progress!, height: 6),
                    ],
                    const SizedBox(height: 8),
                    AppText(n.time, size: 12, color: AppColors.slate500),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
