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
              AppText('Ard Card', size: 20, weight: FontWeight.w700),
              const SizedBox(height: 2),
              AppText(
                'Халаасны данснаас зарцуулна',
                size: 13,
                color: AppColors.slate500,
              ),
            ],
          ),
        ),
        frozen
            ? const StatusBadge(label: 'Түр хаасан', tone: BadgeTone.amber)
            : const StatusBadge(label: 'Идэвхтэй', tone: BadgeTone.emerald),
      ],
    );
  }
}
