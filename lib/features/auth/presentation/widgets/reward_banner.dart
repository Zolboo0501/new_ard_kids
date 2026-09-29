import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class RewardBanner extends StatelessWidget {
  const RewardBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final base = inter(
      size: 11.5,
      weight: FontWeight.w600,
      color: Night.text2,
      height: 1.25,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Night.lime.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.card_giftcard_rounded,
              size: 16,
              color: Night.lime,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: base,
                children: [
                  const TextSpan(
                    text: 'Хүсэлт баталгаажсанаар та болон таны найз тус бүр ',
                  ),
                  TextSpan(
                    text: '+₮10,000',
                    style: base.copyWith(
                      color: Night.lime,
                      fontWeight: FontWeight.w700,
                      fontVariations: const [FontVariation.weight(700)],
                      decoration: TextDecoration.underline,
                      decorationColor: Night.lime,
                    ),
                  ),
                  const TextSpan(text: ' бэлэг авна!'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
