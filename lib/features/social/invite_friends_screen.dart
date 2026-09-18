import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';

/// "Найз урих - Урамшуулал": share an invite code and track invitees.
class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  static const _code = 'POCKET-ANAR26';

  static const _invited = [
    ('Anar B.', '2025.02.14-нд нэгдсэн', true, AppColors.sky50),
    ('Misheel T.', '2025.02.10-нд нэгдсэн', true, AppColors.amber50),
    ('Temuulen E.', 'Урилга илгээсэн', false, AppColors.slate100),
  ];

  void _copy(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _code));
    showAppSnack(context, 'Урилгын код хуулагдлаа');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBackground,
      appBar: const SubPageHeader(title: 'Найз урих'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          AppCard(
            radius: 24,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const MascotImage(
                  asset: Mascots.foxWave,
                  size: 128,
                  background: Colors.white,
                  semanticLabel: 'Найз урих урамшууллын зураг',
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    text: 'Найзаа уриад ',
                    children: [
                      TextSpan(
                        text: '₮ 5,000',
                        style: comfortaa(
                          size: 20,
                          weight: FontWeight.w800,
                          color: AppColors.sky600,
                        ),
                      ),
                      const TextSpan(text: ' урамшуулал аваарай!'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: comfortaa(
                    size: 20,
                    weight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text:
                        'Таны хуваалцсан урилгын кодоор найз тань бүртгүүлж дансаа нээхэд та хоёрт хоёуланд нь урамшууллын ',
                    children: [
                      TextSpan(
                        text: '5,000 оноо',
                        style: comfortaa(
                          size: 12,
                          weight: FontWeight.w700,
                          color: AppColors.slate700,
                        ),
                      ),
                      const TextSpan(text: ' дансанд орно.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: comfortaa(
                    size: 12,
                    weight: FontWeight.w500,
                    color: AppColors.slate500,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            radius: 24,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.pin_outlined,
                      size: 16,
                      color: AppColors.sky600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: AppText(
                        'Таны урилгын код',
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.slate700,
                      ),
                    ),
                    const StatusBadge(
                      label: 'Идэвхтэй',
                      tone: BadgeTone.emerald,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                  decoration: BoxDecoration(
                    color: AppColors.sky50.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.sky100),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'УРИЛГЫН КОД',
                              size: 10,
                              weight: FontWeight.w600,
                              color: AppColors.slate400,
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              child: Text(
                                _code,
                                style: moneyStyle(
                                  size: 18,
                                  weight: FontWeight.w800,
                                  color: AppColors.sky600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SoftButton(
                        label: 'Хуулах',
                        icon: Icons.content_copy_rounded,
                        height: 36,
                        background: AppColors.sky500,
                        foreground: Colors.white,
                        border: null,
                        onPressed: () => _copy(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final (i, s) in [
                      (Icons.share_rounded, 'Хуваалцах'),
                      (Icons.chat_outlined, 'Мессенжер'),
                      (Icons.sms_outlined, 'SMS'),
                      (Icons.qr_code_2_rounded, 'QR код'),
                    ].indexed) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _ShareButton(
                          icon: s.$1,
                          label: s.$2,
                          onTap: () => i == 3
                              ? context.push(AppRoutes.qrScan)
                              : _copy(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            radius: 24,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 16,
                      color: AppColors.amber500,
                    ),
                    const SizedBox(width: 6),
                    AppText(
                      'Яаж ажилладаг вэ? (Алхам алхмаар)',
                      size: 13,
                      weight: FontWeight.w700,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final (i, step) in [
                  (
                    'Урилгын кодоо найздаа илгээх',
                    'Код эсвэл шууд линкийг найзууддаа хуваалцаарай.',
                  ),
                  (
                    'Найз тань PocketPal-д бүртгүүлэх',
                    'Таны кодоор шинэ данс нээж баталгаажуулна.',
                  ),
                  (
                    'Хоёулаа шууд ₮ 5,000 урамшуулал авах!',
                    'Бэлэг автоматаар таны урамшууллын дансанд орно.',
                  ),
                ].indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == 2
                                ? AppColors.emerald100
                                : AppColors.sky100,
                          ),
                          child: AppText(
                            '${i + 1}',
                            size: 12,
                            weight: FontWeight.w700,
                            color: i == 2
                                ? AppColors.emerald600
                                : AppColors.sky600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                step.$1,
                                size: 12,
                                weight: FontWeight.w700,
                              ),
                              const SizedBox(height: 2),
                              AppText(
                                step.$2,
                                size: 11,
                                color: AppColors.slate400,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionHeader(
            title: 'Урьсан найзууд',
            icon: Icons.group_add_outlined,
            action: '${_invited.length} найз',
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          ),
          for (final f in _invited) ...[
            AppCard(
              radius: 18,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: f.$4,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.sky100),
                    ),
                    child: AppText(
                      f.$1.split(' ').map((w) => w[0]).join(),
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.slate600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(f.$1, size: 13, weight: FontWeight.w700),
                        AppText(f.$2, size: 11, color: AppColors.slate400),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        f.$3 ? '+₮ 5,000' : '₮ 5,000',
                        style: moneyStyle(
                          size: 13,
                          weight: FontWeight.w800,
                          color: f.$3
                              ? AppColors.emerald600
                              : AppColors.slate400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      StatusBadge(
                        label: f.$3 ? 'Баталгаажсан' : 'Хүлээгдэж буй',
                        tone: f.$3 ? BadgeTone.emerald : BadgeTone.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Найзуудтайгаа хуваалцах',
            leadingIcon: Icons.rocket_launch_outlined,
            onPressed: () => _copy(context),
          ),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.sky50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: AppColors.sky600),
              ),
              const SizedBox(height: 4),
              AppText(
                label,
                size: 10,
                weight: FontWeight.w700,
                color: AppColors.slate700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
