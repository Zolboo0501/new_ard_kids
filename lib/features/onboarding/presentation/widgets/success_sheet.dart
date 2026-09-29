import 'package:flutter/material.dart';

import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class SuccessSheet extends StatelessWidget {
  const SuccessSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.emerald50,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: LineIcon(
                LineGlyph.check,
                size: 28,
                stroke: 2,
                color: AppColors.emerald600,
              ),
            ),
            const SizedBox(height: 12),
            AppText(
              'Хүсэлт илгээгдлээ',
              size: 18,
              weight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            AppText(
              'Эцэг эх чинь апп дээрээ зөвшөөрмөгц өдрийн гүйлгээний эрх '
              '${formatMnt(Limits.dailyTransfer)} болно.',
              size: 14,
              color: AppColors.slate500,
              height: 1.6,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Ойлголоо',
              height: 50,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
