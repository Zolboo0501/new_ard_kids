import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ignore: unused_import — used by the commented-out "Нас" tile below.
import '../../../../app/age_group.dart';
import '../../../../app/kid_profile.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/group_label.dart';
import '../widgets/profile_identity_card.dart';
import '../widgets/profile_parent_card.dart';
import '../widgets/setting_tile.dart';
import '../widgets/settings_group.dart';

/// "Профайл": who the teen is, the parent link and the settings entry points.
///
/// With [embedded] it is shown as a tab inside the home shell (no back button
/// and extra bottom padding for the floating nav bar).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: AppText(
          'Системээс гарах уу?',
          size: 17,
          weight: FontWeight.w700,
        ),
        content: AppText(
          'Дахин нэвтрэхэд утасны дугаар болон код шаардлагатай.',
          size: 14,
          color: AppColors.slate500,
        ),
        actions: [
          TextButton(
            onPressed: withHaptic(() => Navigator.of(context).pop(false)),
            child: AppText(
              'Болих',
              size: 14,
              weight: FontWeight.w600,
              color: AppColors.slate600,
            ),
          ),
          TextButton(
            onPressed: withHaptic(() => Navigator.of(context).pop(true)),
            child: AppText(
              'Гарах',
              size: 14,
              weight: FontWeight.w600,
              color: AppColors.rose600,
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    context.go(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.pageBackgroundMuted;
    void go(String r) => context.push(r);
    final bottom = embedded
        ? AppLayout.navClearance(context) - 10
        : MediaQuery.paddingOf(context).bottom + 24;

    // Split on wide windows: who the teen is on the left, settings on the
    // right.
    final body = EntranceScope(
      child: AdaptiveSplit(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottom),
        gap: 18,
        leading: [
          ProfileIdentityCard(
            name: Kid.shortName,
            subtitle: Kid.handle,
            status: 'Эцэг эх холбогдсон',
            onAvatarTap: () => go(AppRoutes.avatarPickerEdit),
          ),
          const SizedBox(height: 24),
          const GroupLabel('Эцэг эхийн холболт'),
          ProfileParentCard(onManage: () => go(AppRoutes.parentLink)),
        ],
        trailing: [
          const GroupLabel('Тохиргоо'),
          SettingsGroup(
            children: [
              SettingTile(
                glyph: LineGlyph.profile,
                title: 'Хувийн мэдээлэл',
                onTap: () => go(AppRoutes.personalInfo),
              ),
              SettingTile(
                glyph: LineGlyph.camera,
                title: 'Аватар',
                onTap: () => go(AppRoutes.avatarPickerEdit),
              ),
              // Hidden for now: registration no longer asks for the age, so
              // every account stays on the 14–18 set.
              // ValueListenableBuilder(
              //   valueListenable: appAgeGroup,
              //   builder: (_, age, _) => SettingTile(
              //     // Under 10 the graduation cap, which shows the
              //     // companion's "study" sticker; the calendar has none.
              //     glyph: age == AgeGroup.under10
              //         ? LineGlyph.graduation
              //         : LineGlyph.calendar,
              //     title: 'Нас',
              //     onTap: () => go(AppRoutes.ageGroupEdit),
              //   ),
              // ),
              // Hidden for now: both open from the Home header (gear, bell).
              // SettingTile(
              //   glyph: LineGlyph.shield,
              //   title: 'Аюулгүй байдал',
              //   subtitle: 'ПИН код, биометр, төхөөрөмж',
              //   onTap: () => go(AppRoutes.security),
              // ),
              SettingTile(
                glyph: LineGlyph.palette,
                title: 'Миний өнгө',
                onTap: () => go(AppRoutes.themeSettings),
              ),
              // SettingTile(
              //   glyph: LineGlyph.bell,
              //   title: 'Мэдэгдэл',
              //   subtitle: 'Гүйлгээ, хүсэлт, зорилго',
              //   onTap: () => go(AppRoutes.notifications),
              // ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsGroup(
            children: [
              SettingTile(
                glyph: LineGlyph.gift,
                title: 'Найз урих',
                subtitle:
                    // A no-break space keeps "тус бүр" together.
                    'Урилгаар бүртгүүлбэл та хоёр тус\u00A0бүр '
                    '${formatMnt(Limits.inviteBonus)} авна',
                onTap: () => go(AppRoutes.inviteFriends),
              ),
            ],
          ),
          // Sign-out sits apart from the settings above it.
          const SizedBox(height: 28),
          SettingsGroup(
            children: [
              SettingTile(
                glyph: LineGlyph.logout,
                title: 'Системээс гарах',
                destructive: true,
                onTap: () => _logout(context),
              ),
            ],
          ),
        ],
      ),
    );

    if (embedded) {
      return ColoredBox(
        color: bg,
        child: Column(
          children: [
            SubPageHeader(
              title: 'Миний профайл',
              background: bg,
              showBack: false,
            ),
            Expanded(child: body),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(title: 'Миний профайл', background: bg),
      body: body,
    );
  }
}
