import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class LinkParentBanner extends StatelessWidget {
  const LinkParentBanner({
    super.key,
    required this.onClose,
    required this.onLink,
  });

  final VoidCallback onClose;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: null,
      child: AppCard(
        dashed: true,
        borderColor: AppColors.amber400,
        color: AppColors.amber50,
        radius: 24,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Эцэг эхтэйгээ холбогдох',
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.amber800,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        'Эрхээ 5 дахин нэмэгдүүлж, хадгаламж болон урамшууллын дансаа идэвхжүүлээрэй!',
                        size: 11,
                        color: AppColors.slate600,
                        height: 1.4,
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Хаах',
                  child: GestureDetector(
                    onTap: withHaptic(onClose),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.slate400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.amber100),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Өдрийн лимит: ',
                        children: [
                          TextSpan(
                            text: '₮20,000 / ₮20,000',
                            style: inter(
                              size: 10,
                              weight: FontWeight.w700,
                              color: AppColors.amber600,
                            ),
                          ),
                        ],
                      ),
                      style: inter(
                        size: 10,
                        weight: FontWeight.w500,
                        color: AppColors.slate500,
                      ),
                    ),
                  ),
                  const StatusBadge(
                    label: 'Хязгаарлагдмал',
                    tone: BadgeTone.amber,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Эцэг эхээ холбох ',
              height: 40,
              onPressed: onLink,
            ),
          ],
        ),
      ),
    );
  }
}
