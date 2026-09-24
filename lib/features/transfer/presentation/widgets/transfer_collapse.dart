import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/value_switcher.dart';

/// Shows or hides [child] by folding it open/closed while it fades, so the
/// content below slides instead of jumping.
class TransferCollapse extends StatelessWidget {
  const TransferCollapse({
    super.key,
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueSwitcher(
      value: visible,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      switchInCurve: appEmphasizedDecelerate,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation, _) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          alignment: AlignmentDirectional.topStart,
          child: child,
        ),
      ),
      child: visible
          ? KeyedSubtree(key: const ValueKey(true), child: child)
          : const SizedBox(key: ValueKey(false), width: double.infinity),
    );
  }
}
