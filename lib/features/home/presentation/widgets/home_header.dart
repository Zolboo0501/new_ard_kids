import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/avatar.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// Home's top bar on the night canvas: the companion portrait (opens
/// Profile) with the greeting, and the bell and settings on the right.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.linked,
    required this.avatar,
    required this.onNotifications,
    required this.onSettings,
  });

  final bool linked;
  final AppAvatar avatar;
  final VoidCallback onNotifications;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Night.bg,
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: SizedBox(
        height: 68,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
          child: Row(
            children: [
              GestureDetector(
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
                    color: Night.surface2,
                    shape: BoxShape.circle,
                    border: Border.all(color: Night.line),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    avatar.portrait,
                    fit: BoxFit.cover,
                    semanticLabel: 'Тэмүүлэн',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      'Сайн уу,',
                      size: 12,
                      weight: FontWeight.w500,
                      color: Night.text2,
                    ),
                    AppText(
                      'Тэмүүлэн!',
                      size: 17,
                      weight: FontWeight.w700,
                      color: Night.text,
                      letterSpacing: -0.3,
                    ),
                    if (!linked)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: AppText(
                          'Эцэг эх холбогдоогүй',
                          size: 10.5,
                          weight: FontWeight.w600,
                          color: Night.amber,
                        ),
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

/// A bare white icon with a 44pt hit area, as on the reference.
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
              LineIcon(icon, size: 24, color: Night.text),
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
