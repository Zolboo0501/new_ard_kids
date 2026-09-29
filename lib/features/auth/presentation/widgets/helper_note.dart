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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: LineIcon(
              LineGlyph.mail,
              size: 18,
              color: AppColors.slate500,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            // The copy changes with the mode, so cross-fade it instead of
            // snapping to the new sentence.
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
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
