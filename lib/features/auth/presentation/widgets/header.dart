import 'package:flutter/material.dart';
import 'package:new_ard_kids/theme/app_theme.dart';
import 'package:new_ard_kids/widgets/common.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    this.step,
    this.trailing,
    this.back = true,
    this.onBack,
    this.progress = 1,
  });

  /// Registration progress, omitted when editing an existing profile.
  final String? step;
  final Widget? trailing;

  /// False on the first step (sign-up), which has nothing to go back to.
  final bool back;

  /// What the back button does; null pops the route.
  final VoidCallback? onBack;

  /// How much of the current step's segment is filled, 0–1: sign-up asks
  /// its three questions inside step 1 and fills it a third at a time.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final match = RegExp(r'(\d+)/(\d+)').firstMatch(step ?? '');
    final current = match == null ? 0 : int.parse(match.group(1)!);
    final total = match == null ? 0 : int.parse(match.group(2)!);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              if (back) ...[
                CircleBackButton(onPressed: onBack),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: step == null
                    ? const SizedBox.shrink()
                    // "Алхам 2" in ink, "/6" quieter, so the step you are
                    // on is what reads first.
                    : Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: step!.substring(
                                0,
                                match?.start ?? step!.length,
                              ),
                              style: inter(
                                size: 13,
                                weight: FontWeight.w600,
                                color: AppColors.slate500,
                              ),
                            ),
                            if (match != null) ...[
                              TextSpan(
                                text: '$current',
                                style: inter(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: AppColors.slate900,
                                ),
                              ),
                              TextSpan(
                                text: '/$total',
                                style: inter(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: AppColors.slate400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
              ?trailing,
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 14),
            Semantics(
              label: 'Бүртгэлийн явц',
              value: '$total алхмын $current',
              child: ExcludeSemantics(
                child: _StepProgress(
                  current: current,
                  total: total,
                  progress: progress,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The step bar: finished steps solid in the accent, the current one filling
/// in as the screen opens, the rest a pale accent track.
class _StepProgress extends StatelessWidget {
  const _StepProgress({
    required this.current,
    required this.total,
    required this.progress,
  });

  final int current;
  final int total;
  final double progress;

  static const _height = 6.0;

  @override
  Widget build(BuildContext context) {
    final fill = AppColors.sky500;
    final track = AppColors.sky100;
    return TweenAnimationBuilder<double>(
      // Animates from wherever it is, so a new [progress] eases on.
      tween: Tween(begin: 0, end: progress),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 700),
      curve: appEmphasizedDecelerate,
      builder: (context, t, _) => Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: _height,
                decoration: BoxDecoration(
                  color: track,
                  borderRadius: BorderRadius.circular(_height),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  heightFactor: 1,
                  widthFactor: i < current - 1
                      ? 1
                      : i == current - 1
                      ? t
                      : 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(_height),
                      // The step you are on glows a little, so it reads as
                      // "here" rather than as one more finished step.
                      boxShadow: i == current - 1 && !AppColors.isDark
                          ? [
                              BoxShadow(
                                color: fill.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
