import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';

class PersonalInfoRow extends StatelessWidget {
  const PersonalInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final Widget value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.slate400),
          ),
          const SizedBox(width: 10),
          AppText(
            label,
            size: 12,
            weight: FontWeight.w500,
            color: AppColors.slate500,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: DefaultTextStyle(
                style: inter(
                  size: 12,
                  weight: FontWeight.w600,
                  color: AppColors.slate700,
                ),
                textAlign: TextAlign.right,
                child: value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
