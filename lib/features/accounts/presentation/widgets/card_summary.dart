import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// The card's name, status and the account it spends from.
class CardSummary extends StatelessWidget {
  const CardSummary({super.key, required this.frozen});

  final bool frozen;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('Junior Card', size: 18, weight: FontWeight.w700),
              const SizedBox(height: 2),
              AppText(
                'Халаасны үндсэн данс',
                size: 11,
                weight: FontWeight.w500,
                color: AppColors.slate500,
              ),
            ],
          ),
        ),
        frozen
            ? const StatusBadge(
                label: 'Түр хаасан',
                tone: BadgeTone.amber,
                icon: Icons.ac_unit_rounded,
              )
            : const StatusBadge(label: 'Идэвхтэй', tone: BadgeTone.emerald),
      ],
    );
  }
}
