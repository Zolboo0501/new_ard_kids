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
    const labels = ['Хадгалсан', 'Дансаар', 'Утсаар'];
    final count = TransferMode.values.length;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _duration;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
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
                    color: AppColors.sky500,
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
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: duration,
                            curve: appEmphasizedDecelerate,
                            style: inter(
                              size: 13,
                              weight: m == mode
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: m == mode
                                  ? AppColors.onAccent
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
