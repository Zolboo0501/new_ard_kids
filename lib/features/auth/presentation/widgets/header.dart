import 'package:flutter/material.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/common.dart';
import '../../../../widgets/app_text.dart';

class Header extends StatelessWidget {
  const Header({super.key, this.step, this.trailing});

  /// The registration step pill ("Алхам 2/7"). Leave it null outside the
  /// sign-up flow and only the back button (and [trailing]) show.
  final String? step;

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
          if (step case final step?)
            AppText(
              step,
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.slate500,
            ),
          if (trailing != null)
            Align(alignment: Alignment.centerRight, child: trailing),
        ],
      ),
    );
  }
}
