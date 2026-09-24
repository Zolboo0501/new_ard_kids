import 'package:flutter/material.dart';

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.emerald100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 30,
                color: AppColors.emerald600,
              ),
            ),
            const SizedBox(height: 12),
            AppText(
              'Хүсэлт амжилттай илгээгдлээ!',
              size: 16,
              weight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            AppText(
              'Таны сонгосон асран хамгаалагч руу мэдэгдэл илгээгдлээ. Зөвшөөрсний дараа таны эрх шууд 5 дахин нэмэгдэх болно.',
              size: 12,
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
