import 'package:flutter/material.dart';

import '../../../../app/avatar.dart';
import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// The parent link, who first: the parent as a person (initials, name, role,
/// bank and that the link is on), then today's limit as one compact line
/// over a bar, then the button to manage the link.
class ProfileParentCard extends StatelessWidget {
  const ProfileParentCard({super.key, required this.onManage});

  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ParentRow(),
          Divider(height: 32, thickness: 1, color: AppColors.line),
          const _TodayLimit(),
          const SizedBox(height: 16),
          SoftButton(
            label: 'Холболтыг удирдах',

            height: 46,
            background: AppColors.sky50,
            foreground: AppColors.sky700,
            border: Colors.transparent,
            onPressed: onManage,
          ),
        ],
      ),
    );
  }
}

/// Who is linked: a large initials avatar, the name with the role beside it,
/// and the bank with the link's state under it.
class _ParentRow extends StatelessWidget {
  const _ParentRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ExcludeSemantics(child: _ParentPicture()),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: AppText(
                      'Б. Саруул',
                      size: 17,
                      weight: FontWeight.w700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: AppText(
                      'Ээж',
                      size: 12,
                      weight: FontWeight.w600,
                      color: AppColors.slate600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 2,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.emerald500,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      AppText(
                        'Холбоотой',
                        size: 13,
                        weight: FontWeight.w600,
                        color: AppColors.emerald600,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Today's limit in one line (left of the whole), with the bar under it.
class _TodayLimit extends StatelessWidget {
  const _TodayLimit();

  @override
  Widget build(BuildContext context) {
    const left = Limits.leftToday;
    const limit = Limits.dailyTransfer;
    return Semantics(
      label:
          'Өнөөдөр ${formatMnt(left)} үлдсэн, '
          'өдрийн хязгаар ${formatMnt(limit)}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: AppText(
                  'Лимит',
                  size: 14,
                  weight: FontWeight.w500,
                  color: AppColors.slate600,
                ),
              ),
              BalanceText(
                left,
                size: 17,
                weight: FontWeight.w700,
                color: AppColors.emerald600,
              ),
              AppText(
                ' / ${formatMnt(limit)}',
                size: 14,
                weight: FontWeight.w500,
                color: AppColors.slate400,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProgressTrack(
            value: left / limit,
            height: 8,
            color: AppColors.sky500,
          ),
        ],
      ),
    );
  }
}

/// The parent's picture: the chosen companion's "mom" sticker (so it is
/// theirs, but not the teen's own portrait) on a soft accent disc; 14+ has
/// no companion stickers on cards, so it shows the parent's initials.
class _ParentPicture extends StatelessWidget {
  const _ParentPicture();

  static const _size = 56.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.sky100,
        shape: BoxShape.circle,
      ),
      child: Stickers.onCards
          ? ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  Stickers.mom,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  cacheWidth: (_size * 3).round(),
                  errorBuilder: (_, _, _) => const _Initials(),
                ),
              ),
            )
          : const _Initials(),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials();

  @override
  Widget build(BuildContext context) {
    return AppText(
      'БС',
      size: 18,
      weight: FontWeight.w700,
      color: AppColors.sky700,
    );
  }
}
