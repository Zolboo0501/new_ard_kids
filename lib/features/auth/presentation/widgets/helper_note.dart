import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../../../widgets/value_switcher.dart';

class HelperNote extends StatelessWidget {
  const HelperNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    // A tinted note in the accent's lightest step, so it reads as help
    // rather than as another field.
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.sky50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: LineIcon(LineGlyph.mail, size: 17, color: AppColors.sky600),
          ),
          const SizedBox(width: 10),
          Expanded(
            // The copy changes with the mode, so cross-fade it instead of
            // snapping to the new sentence.
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 240),
                curve: appEmphasizedDecelerate,
                alignment: Alignment.topLeft,
                child: ValueSwitcher(
                  value: text,
                  // Start-aligned beside the icon; the default centres a
                  // sentence shorter than the row (iPad's full width).
                  layoutBuilder: (current, previous) => Stack(
                    alignment: AlignmentDirectional.topStart,
                    children: [...previous, ?current],
                  ),
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: appEmphasizedDecelerate,
                  switchOutCurve: appEmphasizedAccelerate,
                  child: AppText(
                    text,
                    size: 13,
                    color: AppColors.slate600,
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
