import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import 'profile_avatar.dart';

/// Gradient header with avatar, "Сурагчийн карт" chip, name and ID.
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.sky50, AppColors.emerald50],
        ),
        border: Border.all(color: AppColors.sky100),
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
                          border: Border.all(color: Colors.white, width: 2),
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
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.slate100),
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
