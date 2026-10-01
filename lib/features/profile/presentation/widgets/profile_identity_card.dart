import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import 'profile_avatar.dart';

/// Who the teen is: avatar, name, a secondary line and a status line.
/// With [onAvatarTap] the avatar opens the avatar picker.
class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.status,
    this.onAvatarTap,
  });

  final String name;
  final String subtitle;

  /// A short verified line under the name, drawn with a check.
  final String? status;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    Widget avatar = const ProfileAvatar(size: 72);
    if (onAvatarTap != null) {
      avatar = Semantics(
        button: true,
        label: 'Аватар солих',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: withHaptic(onAvatarTap),
          // A small pen on the ring says the picture can be changed.
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              Positioned(
                right: -2,
                bottom: -2,
                child: ExcludeSemantics(
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.sky500,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.card, width: 2.5),
                    ),
                    child: LineIcon(
                      LineGlyph.edit,
                      size: 13,
                      color: AppColors.onAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(name, size: 20, weight: FontWeight.w700),
                const SizedBox(height: 2),
                AppText(subtitle, size: 14, color: AppColors.slate500),
                if (status != null) ...[
                  const SizedBox(height: 10),
                  // Each part of the status ("Баталгаажсан", "Эцэг эх
                  // холбогдсон") is its own chip, so a narrow card wraps
                  // between them instead of mid-phrase.
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final part in status!.split(' · '))
                        _StatusChip(part),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
      decoration: BoxDecoration(
        color: AppColors.emerald50,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LineIcon(
            LineGlyph.checkCircle,
            size: 14,
            color: AppColors.emerald600,
          ),
          const SizedBox(width: 4),
          // Wraps inside the chip on the narrowest phones.
          Flexible(
            child: AppText(
              label,
              size: 12,
              weight: FontWeight.w600,
              color: AppColors.emerald700,
            ),
          ),
        ],
      ),
    );
  }
}
