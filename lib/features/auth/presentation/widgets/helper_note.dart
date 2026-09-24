import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/value_switcher.dart';

class HelperNote extends StatelessWidget {
  const HelperNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.sky50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.sms_outlined, size: 14, color: AppColors.sky600),
          ),
          const SizedBox(width: 10),
          Expanded(
            // The copy changes with the mode, so cross-fade it instead of
            // snapping to the new sentence.
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 240),
                curve: appEmphasizedDecelerate,
                alignment: Alignment.topCenter,
                child: ValueSwitcher(
                  value: text,
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: appEmphasizedDecelerate,
                  switchOutCurve: appEmphasizedAccelerate,
                  child: AppText(
                    text,
                    size: 12,
                    weight: FontWeight.w500,
                    color: AppColors.slate500,
                    height: 1.4,
                    key: ValueKey(text),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
