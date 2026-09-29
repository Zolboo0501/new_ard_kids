import 'package:flutter/material.dart';

import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// The one prompt an unlinked teen sees on Home: what linking a parent
/// unlocks, and a button to do it.
class HomeLinkPrompt extends StatelessWidget {
  const HomeLinkPrompt({super.key, required this.onLink});

  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      shadow: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.sky50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: LineIcon(
                    LineGlyph.link,
                    size: 21,
                    color: AppColors.sky600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Эцэг эхтэйгээ холбогдох',
                      size: 15,
                      weight: FontWeight.w700,
                      color: AppColors.slate900,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      'Өдрийн хязгаар ${formatMnt(Limits.unlinkedDaily)}-с '
                      '${formatMnt(Limits.dailyTransfer)} болж, хадгаламж, '
                      'хөрөнгө оруулалт, койны данс нээгдэнэ.',
                      size: 13,
                      color: AppColors.slate500,
                      height: 1.45,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Холбох', height: 48, onPressed: onLink),
        ],
      ),
    );
  }
}
