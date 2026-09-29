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
        borderColor: Night.amber.withValues(alpha: 0.6),
        color: Night.surface,
        shadow: false,
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
                        color: Night.amber,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        'Эрхээ 5 дахин нэмэгдүүлж, хадгаламж болон урамшууллын дансаа идэвхжүүлээрэй!',
                        size: 11.5,
                        color: Night.text2,
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
                      child: LineIcon(
                        LineGlyph.close,
                        size: 16,
                        color: Night.text2,
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
                color: Night.surface2,
                borderRadius: BorderRadius.circular(16),
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
                              color: Night.amber,
                            ),
                          ),
                        ],
                      ),
                      style: inter(
                        size: 10,
                        weight: FontWeight.w500,
                        color: Night.text2,
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
            Semantics(
              button: true,
              child: Pressable(
                onTap: onLink,
                scale: 0.97,
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.sky500,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AppText(
                    'Эцэг эхээ холбох',
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.onAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
