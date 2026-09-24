import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/avatar.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.linked,
    required this.avatar,
    required this.onNotifications,
  });

  final bool linked;
  final AppAvatar avatar;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      decoration: BoxDecoration(
        color: kPageBackground.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: AppColors.sky100.withValues(alpha: 0.6)),
        ),
      ),
      child: SizedBox(
        height: 68,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  width: 46,
                  height: 46,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.sky100,
                    border: Border.all(
                      color: AppColors.sky500.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      avatar.portrait,
                      fit: BoxFit.cover,
                      semanticLabel: 'Тэмүүлэн',
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
                    Row(
                      children: [
                        AppText(
                          'Сайн уу',
                          size: 11,
                          weight: FontWeight.w600,
                          color: AppColors.slate500,
                        ),
                        const SizedBox(width: 4),
                        MascotIcon(Stickers.success, size: 16),
                      ],
                    ),
                    AppText(
                      'Тэмүүлэн!',
                      size: 17,
                      weight: FontWeight.w500,
                      letterSpacing: -0.3,
                    ),
                    if (!linked)
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: StatusBadge(
                          label: 'Эцэг эх холбогдоогүй',
                          tone: BadgeTone.amber,
                        ),
                      ),
                  ],
                ),
              ),
              CircleIconButton(
                icon: Icons.notifications_none_rounded,
                label: 'Мэдэгдэл',
                badge: true,
                onPressed: onNotifications,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
