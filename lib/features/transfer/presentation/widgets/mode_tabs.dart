import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/ui.dart';
import '../screens/transfer_screen.dart';

class ModeTabs extends StatelessWidget {
  const ModeTabs({super.key, required this.mode, required this.onChanged});

  final TransferMode mode;
  final ValueChanged<TransferMode> onChanged;

  static const _duration = Duration(milliseconds: 320);

  @override
  Widget build(BuildContext context) {
    const labels = ['Найзууд', 'Дансаар', 'Утсаар'];
    final count = TransferMode.values.length;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _duration;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.slate100.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // One pill that slides to the selected tab, instead of each tab
          // painting its own and the highlight jumping.
          Positioned.fill(
            child: AnimatedAlign(
              duration: duration,
              curve: appEmphasizedDecelerate,
              alignment: Alignment(-1 + 2 * mode.index / (count - 1), 0),
              child: FractionallySizedBox(
                widthFactor: 1 / count,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [AppColors.sky500, AppColors.sky600],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sky500.withValues(alpha: 0.35),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final m in TransferMode.values)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: m == mode,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: withHaptic(() => onChanged(m)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: duration,
                            curve: appEmphasizedDecelerate,
                            style: inter(
                              size: 12,
                              weight: m == mode
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: m == mode
                                  ? Colors.white
                                  : AppColors.slate500,
                            ),
                            child: Text(labels[m.index]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
