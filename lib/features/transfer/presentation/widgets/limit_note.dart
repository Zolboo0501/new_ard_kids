import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class LimitNote extends StatelessWidget {
  const LimitNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sky50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sky200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.sky100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shield_outlined,
              size: 15,
              color: AppColors.sky600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Энэ гүйлгээ нь аав ээжийн тохируулсан ',
                children: [
                  TextSpan(
                    text: 'өдрийн ₮100,000 лимитийн',
                    style: inter(
                      size: 11,
                      weight: FontWeight.w700,
                      color: AppColors.sky900,
                    ),
                  ),
                  const TextSpan(text: ' хүрээнд хамгаалагдсан байна.'),
                ],
              ),
              style: inter(
                size: 11,
                weight: FontWeight.w500,
                color: AppColors.sky700,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
