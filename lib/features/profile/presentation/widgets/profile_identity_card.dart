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
          child: avatar,
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
                  Row(
                    children: [
                      LineIcon(
                        LineGlyph.checkCircle,
                        size: 16,
                        color: AppColors.emerald600,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: AppText(
                          status!,
                          size: 13,
                          weight: FontWeight.w500,
                          color: AppColors.slate600,
                        ),
                      ),
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
