import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class RewardBanner extends StatelessWidget {
  const RewardBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final base = inter(
      size: 11.5,
      weight: FontWeight.w600,
      color: AppColors.emerald800,
      height: 1.25,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.emerald50.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.emerald200.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.emerald100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              size: 16,
              color: AppColors.emerald600,
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
                      color: AppColors.emerald950,
                      fontWeight: FontWeight.w700,
                      fontVariations: const [FontVariation.weight(700)],
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.emerald400,
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
