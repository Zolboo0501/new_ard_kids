import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// Bottom sheet with the scanned value; pops `true` to start a transfer.
class ScanResultSheet extends StatelessWidget {
  const ScanResultSheet({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.emerald50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: AppColors.emerald600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  'QR код уншигдлаа',
                  size: 16,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.slate100),
            ),
            child: AppText(
              value,
              size: 12,
              color: AppColors.slate600,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Гүйлгээ хийх',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => Navigator.pop(context, true),
          ),
          const SizedBox(height: 8),
          SoftButton(
            label: 'Дахин унших',
            icon: Icons.qr_code_scanner_rounded,
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }
}
