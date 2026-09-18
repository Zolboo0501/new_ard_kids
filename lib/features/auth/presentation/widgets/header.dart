import 'package:flutter/material.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/common.dart';
import '../../../../widgets/app_text.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.step, this.trailing});

  final String step;

  /// Optional action pinned to the right of the step pill, for screens that
  /// offer something alongside going back (a skip, for instance).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // No horizontal padding: the screens that use this already inset their
      // own content, so the back button lines up with it.
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: CircleBackButton(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.sky50,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.sky100.withValues(alpha: 0.8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PulsingDot(),
                const SizedBox(width: 6),
                AppText(
                  step,
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.sky600,
                ),
              ],
            ),
          ),
          if (trailing != null)
            Align(alignment: Alignment.centerRight, child: trailing),
        ],
      ),
    );
  }
}
