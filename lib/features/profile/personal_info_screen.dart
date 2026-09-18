import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui.dart';
import 'profile_screen.dart';
import '../../widgets/app_text.dart';

/// "Хувийн мэдээлэл": read-only student profile details.
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _showRegister = false;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF4F8FC);
    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(
        title: 'Хувийн мэдээлэл',
        subtitle: 'Сурагчийн бүртгэл ба тохиргоо',
        background: bg,
        trailing: CircleIconButton(
          icon: Icons.edit_outlined,
          label: 'Засах',
          color: AppColors.sky600,
          onPressed: () => context.push(AppRoutes.editPersonalInfo),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          const StudentHeaderCard(
            subtitle: '12 настай · 6-р анги',
            trailing: StatusBadge(
              label: 'Баталгаажсан',
              tone: BadgeTone.emerald,
              icon: Icons.verified_rounded,
            ),
            onlineDot: true,
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
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.sky50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: AppColors.sky500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        'Үндсэн мэдээлэл',
                        size: 14,
                        weight: FontWeight.w700,
                      ),
                    ),
                    AppText(
                      'Албан ёсны',
                      size: 11,
                      weight: FontWeight.w600,
                      color: AppColors.slate400,
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.slate100),
                const _InfoRow(
                  icon: Icons.badge_outlined,
                  label: 'Бүтэн нэр',
                  value: Text('Бат-Ирээдүй Төмөрбаатар'),
                ),
                const _InfoRow(
                  icon: Icons.cake_outlined,
                  label: 'Төрсөн огноо',
                  value: Text('2014 оны 05 сарын 18'),
                ),
                const _InfoRow(
                  icon: Icons.wc_rounded,
                  label: 'Хүйс',
                  value: Text('Эрэгтэй'),
                ),
                _InfoRow(
                  icon: Icons.fingerprint_rounded,
                  label: 'Регистрийн дугаар',
                  value: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_showRegister ? 'УХ14251812' : 'УХ••••••12'),
                      const SizedBox(width: 4),
                      Semantics(
                        button: true,
                        label: 'Харах эсэх',
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _showRegister = !_showRegister),
                          child: Icon(
                            _showRegister
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 16,
                            color: AppColors.slate400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const _InfoRow(
                  icon: Icons.phone_iphone_rounded,
                  label: 'Утасны дугаар',
                  value: Text('+976 9911 2345'),
                  last: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const InfoNote(
            icon: Icons.lock_outline_rounded,
            text:
                'Хувийн мэдээллийг өөрчлөхөд эцэг эхийн зөвшөөрөл шаардлагатай.',
          ),
        ],
      ),
    );
  }
}

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
        gradient: const LinearGradient(
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
                const StatusBadge(
                  label: 'Сурагчийн карт',
                  icon: Icons.school_outlined,
                ),
                const SizedBox(height: 6),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final Widget value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.slate400),
          ),
          const SizedBox(width: 10),
          AppText(
            label,
            size: 12,
            weight: FontWeight.w500,
            color: AppColors.slate500,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: DefaultTextStyle(
                style: comfortaa(
                  size: 12,
                  weight: FontWeight.w600,
                  color: AppColors.slate700,
                ),
                textAlign: TextAlign.right,
                child: value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
