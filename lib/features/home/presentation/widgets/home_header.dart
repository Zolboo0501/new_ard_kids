import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/avatar.dart';
import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// Home's top bar: the teen's avatar (opens Profile) with the greeting,
/// and the bell and settings on the right.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.avatar,
    required this.onNotifications,
    required this.onSettings,
  });

  final AppAvatar avatar;
  final VoidCallback onNotifications;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: SizedBox(
        height: 68,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: 'Профайл',
                excludeSemantics: true,
                child: GestureDetector(
                  // Switch to the Profile tab (branch 1) like the nav bar does,
                  // so the bar's selection follows instead of a page on top.
                  onTap: () {
                    HapticFeedback.selectionClick();
                    StatefulNavigationShell.of(context).goBranch(1);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.line),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      avatar.portrait,
                      fit: BoxFit.cover,
                      semanticLabel: Kid.firstName,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText('Сайн уу,', size: 13, color: AppColors.slate500),
                    AppText(
                      Kid.firstName,
                      size: 17,
                      weight: FontWeight.w700,
                      color: AppColors.slate900,
                      letterSpacing: -0.3,
                    ),
                  ],
                ),
              ),
              _HeaderIcon(
                icon: LineGlyph.bell,
                label: 'Мэдэгдэл',
                badge: true,
                onTap: onNotifications,
              ),
              _HeaderIcon(
                icon: LineGlyph.settings,
                label: 'Тохиргоо',
                onTap: onSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A bare line icon with a 44pt hit area.
class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = false,
  });

  final LineGlyph icon;
  final String label;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Pressable(
        onTap: onTap,
        scale: 0.9,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Iconsax at every age: header actions stay icons, not the
              // companion's stickers.
              PlainLineIcons(
                child: LineIcon(icon, size: 24, color: AppColors.slate900),
              ),
              if (badge)
                Positioned(
                  top: 11,
                  right: 12,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.sky500,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
