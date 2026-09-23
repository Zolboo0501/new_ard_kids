import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/avatar.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';
import '../../widgets/entrance.dart';

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
    final bottom = MediaQuery.paddingOf(context).bottom + (embedded ? 110 : 24);

    final body = EntranceScope(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottom),
        children: EntranceItem.list([
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
                      _LimitRow(
                        label: 'Өдрийн зарцуулалтын хязгаар:',
                        value: 50000,
                        color: AppColors.slate800,
                      ),
                      const SizedBox(height: 6),
                      _LimitRow(
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
          const SizedBox(height: 18),
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
                _MenuTile(
                  icon: Icons.person_outline_rounded,
                  tone: BadgeTone.sky,
                  title: 'Хувийн мэдээлэл',
                  subtitle: 'Төрсөн огноо, сургууль, анги',
                  onTap: () => go(AppRoutes.personalInfo),
                ),
                const Divider(height: 1, indent: 64, color: AppColors.slate100),
                _MenuTile(
                  icon: Icons.pets_rounded,
                  tone: BadgeTone.slate,
                  title: 'Аватар',
                  subtitle: 'Бяцхан туслах найзаа солих',
                  onTap: () => go(AppRoutes.avatarPickerEdit),
                ),
                const Divider(height: 1, indent: 64, color: AppColors.slate100),
                _MenuTile(
                  icon: Icons.shield_outlined,
                  tone: BadgeTone.emerald,
                  title: 'Аюулгүй байдал & ПИН код',
                  subtitle: 'Face ID, 4 оронтой нууц код',
                  onTap: () => go(AppRoutes.security),
                ),
                const Divider(height: 1, indent: 64, color: AppColors.slate100),
                _MenuTile(
                  icon: Icons.palette_outlined,
                  tone: BadgeTone.amber,
                  title: 'Өнгөний тохиргоо',
                  subtitle: 'Цэнхэр, ягаан сэдэв сонгох',
                  onTap: () => go(AppRoutes.themeSettings),
                ),
                const Divider(height: 1, indent: 64, color: AppColors.slate100),
                _MenuTile(
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
        ]),
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

/// Round gradient-ringed avatar used on the profile screens.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.size = 80, this.badge});

  final double size;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [AppColors.sky400, AppColors.emerald300],
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(2),
            // Follows the companion picked in "Аватар сонгох".
            child: ValueListenableBuilder(
              valueListenable: appAvatar,
              builder: (context, avatar, _) => ClipOval(
                child: Image.asset(
                  avatar.portrait,
                  fit: BoxFit.cover,
                  semanticLabel: 'Хүүхдийн профайл зураг',
                ),
              ),
            ),
          ),
        ),
        if (badge != null) Positioned(right: -2, bottom: -2, child: badge!),
      ],
    );
  }
}

class _LimitRow extends StatelessWidget {
  const _LimitRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final num value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: AppText(label, size: 11, color: AppColors.slate500)),
        BalanceText(value, size: 12, color: color),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final BadgeTone tone;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, _) = tone.colors;
    return InkWell(
      onTap: withHaptic(onTap),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: fg),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(title, size: 12, weight: FontWeight.w700),
                  const SizedBox(height: 2),
                  AppText(subtitle, size: 10, color: AppColors.slate400),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.slate300,
            ),
          ],
        ),
      ),
    );
  }
}
