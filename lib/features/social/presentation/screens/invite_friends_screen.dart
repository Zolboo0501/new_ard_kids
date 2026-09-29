import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/social_initials_avatar.dart';

/// "Найз урих": share an invite code and track invitees.
class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  static const _code = 'TEMU26';

  /// (name, status line, joined)
  static const _invited = [
    ('Anar B.', '2026.09.14-нд нэгдсэн', true),
    ('Misheel T.', '2026.08.30-нд нэгдсэн', true),
    ('Tergel E.', 'Урилга илгээсэн', false),
  ];

  void _copy(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _code));
    showAppSnack(context, 'Урилгын код хуулагдлаа');
  }

  Widget _title(String text, {Widget? trailing}) => Row(
    children: [
      Expanded(
        child: AppText(
          text,
          size: 16,
          weight: FontWeight.w700,
          color: AppColors.slate900,
        ),
      ),
      ?trailing,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final bonus = formatMnt(Limits.inviteBonus, space: false);
    final steps = [
      ('Кодоо найздаа илгээнэ', 'Кодыг хуулж эсвэл шууд хуваалцана.'),
      ('Найз тань бүртгүүлнэ', 'Таны кодоор апп-д бүртгүүлж данс нээнэ.'),
      (
        'Урамшуулал орно',
        'Танд болон найзад тань $bonus урамшууллын дансанд орно.',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SubPageHeader(title: 'Найз урих', background: AppColors.surface),
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Урьсан найз бүрт',
                    size: 13,
                    weight: FontWeight.w500,
                    color: AppColors.slate500,
                  ),
                  const SizedBox(height: 4),
                  BalanceText(
                    Limits.inviteBonus,
                    size: 40,
                    weight: FontWeight.w600,
                    space: false,
                    color: AppColors.slate900,
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    'Найз тань таны кодоор бүртгүүлж данс нээхэд та хоёрт '
                    'тус бүр $bonus урамшуулал олгоно.',
                    size: 14,
                    color: AppColors.slate600,
                    height: 1.5,
                  ),
                  Divider(height: 32, color: AppColors.line),
                  _title(
                    'Таны урилгын код',
                    trailing: const StatusBadge(
                      label: 'Идэвхтэй',
                      tone: BadgeTone.emerald,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _code,
                            style: moneyStyle(
                              size: 20,
                              weight: FontWeight.w600,
                              color: AppColors.slate900,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        SoftButton(
                          label: 'Хуулах',
                          leading: LineIcon(
                            LineGlyph.copy,
                            size: 18,
                            color: AppColors.sky600,
                          ),
                          height: 44,
                          border: Colors.transparent,
                          onPressed: () => _copy(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title('Яаж ажилладаг вэ?'),
                  const SizedBox(height: 12),
                  for (final (i, step) in steps.indexed)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == steps.length - 1 ? 0 : 14,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.slate100,
                            ),
                            child: AppText(
                              '${i + 1}',
                              size: 13,
                              weight: FontWeight.w600,
                              color: AppColors.slate700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  step.$1,
                                  size: 14,
                                  weight: FontWeight.w600,
                                  color: AppColors.slate900,
                                ),
                                const SizedBox(height: 2),
                                AppText(
                                  step.$2,
                                  size: 13,
                                  color: AppColors.slate500,
                                  height: 1.4,
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
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
              child: _title(
                'Урьсан найзууд',
                trailing: AppText(
                  '${_invited.length}',
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.slate500,
                ),
              ),
            ),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final (i, f) in _invited.indexed) ...[
                    if (i > 0) Divider(height: 1, color: AppColors.line),
                    ListItemEntrance(
                      id: f,
                      index: i,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            SocialInitialsAvatar(name: f.$1),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    f.$1,
                                    size: 14,
                                    weight: FontWeight.w600,
                                    color: AppColors.slate900,
                                  ),
                                  const SizedBox(height: 2),
                                  AppText(
                                    f.$2,
                                    size: 13,
                                    color: AppColors.slate500,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                BalanceText(
                                  Limits.inviteBonus,
                                  sign: f.$3,
                                  space: false,
                                  size: 14,
                                  weight: FontWeight.w600,
                                  color: f.$3
                                      ? AppColors.emerald600
                                      : AppColors.slate400,
                                ),
                                const SizedBox(height: 4),
                                StatusBadge(
                                  label: f.$3
                                      ? 'Баталгаажсан'
                                      : 'Хүлээгдэж буй',
                                  tone: f.$3
                                      ? BadgeTone.emerald
                                      : BadgeTone.amber,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Урилга хуваалцах',
              onPressed: () => _copy(context),
            ),
          ]),
        ),
      ),
    );
  }
}
