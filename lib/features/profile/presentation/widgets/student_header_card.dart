import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import 'profile_avatar.dart';

/// Night hero panel with avatar, "Сурагчийн карт" chip, name and ID.
class StudentHeaderCard extends StatelessWidget {
  const StudentHeaderCard({
    super.key,
    required this.subtitle,
    required this.trailing,
    this.onlineDot = false,
    this.avatarBadge,
  });

  final String subtitle;
  final Widget trailing;
  final bool onlineDot;
  final Widget? avatarBadge;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.sky500;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        // A faint wash of the theme accent from the top-left corner, like
        // Home's account panels.
        gradient: RadialGradient(
          center: const Alignment(-1, -1),
          radius: 1.4,
          colors: [
            Color.alphaBlend(accent.withValues(alpha: 0.16), AppColors.card),
            AppColors.card,
          ],
        ),
      ),
      child: Row(
        children: [
          ProfileAvatar(
            size: 80,
            badge:
                avatarBadge ??
                (onlineDot
                    ? Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.emerald400,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.card, width: 2),
                        ),
                      )
                    : null),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('Бат-Ирээдүй Т.', size: 16, weight: FontWeight.w700),
                const SizedBox(height: 2),
                AppText(
                  subtitle,
                  size: 12,
                  weight: FontWeight.w600,
                  color: AppColors.slate500,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Night.surface2,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        'ID: 889201',
                        size: 11,
                        weight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                    trailing,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
