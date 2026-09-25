import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/avatar.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/limit_row.dart';
import '../widgets/menu_tile.dart';
import '../widgets/profile_avatar.dart';

/// "Профайл": kid profile, parent link summary and settings entry points.
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: AppText(
          'Системээс гарах уу?',
          size: 16,
          weight: FontWeight.w700,
        ),
        content: AppText(
          'Дахин нэвтрэхэд утасны дугаар болон код шаардлагатай.',
          size: 13,
          color: AppColors.slate500,
        ),
        actions: [
          TextButton(
            onPressed: withHaptic(() => Navigator.of(context).pop(false)),
            child: AppText(
              'Болих',
              size: 13,
              weight: FontWeight.w700,
              color: AppColors.slate500,
            ),
          ),
          TextButton(
            onPressed: withHaptic(() => Navigator.of(context).pop(true)),
            child: AppText(
              'Гарах',
              size: 13,
              weight: FontWeight.w700,
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

    // Split on wide windows: who the kid is on the left, settings on the right.
    final body = EntranceScope(
      child: AdaptiveSplit(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottom),
        gap: 18,
        leading: [
          AppCard(
            radius: 24,
            padding: const EdgeInsets.all(20),
            borderColor: AppColors.slate100,
            child: Column(
              children: [
                Row(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Аватар солих',
                      child: GestureDetector(
                        onTap: withHaptic(
                          () => context.push(AppRoutes.avatarPickerEdit),
                        ),
                        child: ProfileAvatar(
                          size: 80,
                          badge: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.sky500,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          AppText(
                            'Бат-Ирээдүй Т.',
                            size: 20,
                            weight: FontWeight.w700,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            '12 настай • @bat_ireedui',
                            size: 12,
                            color: AppColors.slate400,
                          ),
                          AppText(
                            'ID: 889201',
                            size: 11,
                            color: AppColors.slate400,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28, color: AppColors.slate100),
                Row(
                  children: [
                    AppText(
                      'Дараагийн түвшин',
                      size: 11,
                      weight: FontWeight.w600,
                      color: AppColors.slate500,
                    ),
                    const Spacer(),
                    AppText(
                      '120 / 200 XP',
                      size: 11,
                      weight: FontWeight.w700,
                      color: AppColors.sky600,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const ProgressTrack(value: 0.6, height: 10),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            radius: 24,
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.slate100,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        'ЭЦЭГ ЭХИЙН ХОЛБОЛТ',
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.slate700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const StatusBadge(
                      label: '✓ Идэвхтэй',
                      tone: BadgeTone.emerald,
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.slate100),
                Row(
                  children: [
                    MascotTile(
                      asset: Stickers.mom,
                      background: AppColors.pink50,
                      label: 'Ээж (Б. Саруул)',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Ээж (Б. Саруул)',
                            size: 12,
                            weight: FontWeight.w700,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            'Голомт банк • Баталгаажсан',
                            size: 11,
                            color: AppColors.slate400,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SoftButton(
                      label: 'Хянах',
                      icon: Icons.tune_rounded,
                      height: 40,
                      onPressed: () => go(AppRoutes.parentLink),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.slate50.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate100),
                  ),
                  child: Column(
                    children: [
                      LimitRow(
                        label: 'Өдрийн зарцуулалтын хязгаар:',
                        value: 50000,
                        color: AppColors.slate800,
                      ),
                      const SizedBox(height: 6),
                      LimitRow(
                        label: 'Өнөөдөр үлдсэн:',
                        value: 31300,
                        color: AppColors.emerald600,
                      ),
                      const SizedBox(height: 8),
                      const ProgressTrack(
                        value: 31300 / 50000,
                        height: 6,
                        color: AppColors.emerald500,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        trailing: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: AppText(
              'ТОХИРГОО БА ҮЙЛЧИЛГЭЭ',
              size: 12,
              weight: FontWeight.w700,
              color: AppColors.slate500,
              letterSpacing: 0.6,
            ),
          ),
          AppCard(
            radius: 24,
            padding: EdgeInsets.zero,
            borderColor: AppColors.slate100,
            child: Column(
              children: [
                MenuTile(
                  icon: Icons.person_outline_rounded,
                  tone: BadgeTone.sky,
                  title: 'Хувийн мэдээлэл',
                  subtitle: 'Төрсөн огноо, сургууль, анги',
                  onTap: () => go(AppRoutes.personalInfo),
                ),
                const Divider(height: 1, indent: 64, color: AppColors.slate100),
                MenuTile(
                  icon: Icons.pets_rounded,
                  tone: BadgeTone.slate,
                  title: 'Аватар',
                  subtitle: 'Бяцхан туслах найзаа солих',
                  onTap: () => go(AppRoutes.avatarPickerEdit),
                ),
                const Divider(height: 1, indent: 64, color: AppColors.slate100),
                MenuTile(
                  icon: Icons.shield_outlined,
                  tone: BadgeTone.emerald,
                  title: 'Аюулгүй байдал & ПИН код',
                  subtitle: 'Face ID, 4 оронтой нууц код',
                  onTap: () => go(AppRoutes.security),
                ),
                const Divider(height: 1, indent: 64, color: AppColors.slate100),
                MenuTile(
                  icon: Icons.palette_outlined,
                  tone: BadgeTone.amber,
                  title: 'Өнгөний тохиргоо',
                  subtitle: 'Цэнхэр, ягаан сэдэв сонгох',
                  onTap: () => go(AppRoutes.themeSettings),
                ),
                const Divider(height: 1, indent: 64, color: AppColors.slate100),
                MenuTile(
                  icon: Icons.card_giftcard_rounded,
                  tone: BadgeTone.rose,
                  title: 'Найз урих',
                  subtitle: 'Хоёулаа ₮5,000 урамшуулал аваарай',
                  onTap: () => go(AppRoutes.inviteFriends),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SoftButton(
            label: 'Системээс гарах',
            icon: Icons.logout_rounded,
            height: 52,
            background: AppColors.rose50,
            foreground: AppColors.rose600,
            border: AppColors.rose100,
            onPressed: () => _logout(context),
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
      appBar: SubPageHeader(
        title: 'Миний профайл',
        background: bg,
        trailing: CircleIconButton(
          icon: Icons.settings_outlined,
          label: 'Тохиргоо',
          onPressed: () => go(AppRoutes.security),
        ),
      ),
      body: body,
    );
  }
}
