import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// The top of Home: the teen mascot holding up his card in a neon glow,
/// with the kid's streak and their biggest savings goal beside him. Linked
/// kids see the goal's progress (taps open savings); unlinked kids get an
/// invitation to start instead.
class HomeHero extends StatelessWidget {
  const HomeHero({
    super.key,
    required this.streakDays,
    required this.onTap,
    this.goal,
    this.saved = 0,
    this.target = 0,
  });

  final int streakDays;

  /// The goal's name; null shows the unlinked "start" message.
  final String? goal;
  final int saved;
  final int target;
  final VoidCallback onTap;

  static const height = 212.0;

  @override
  Widget build(BuildContext context) {
    final goal = this.goal;
    final progress = target == 0 ? 0.0 : (saved / target).clamp(0.0, 1.0);
    return Semantics(
      button: true,
      label: goal == null
          ? 'Санхүүгийн аялалаа эхлүүл'
          : '$goal, ${(progress * 100).round()}% хуримтлагдсан',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.98,
        child: LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  // On narrow phones he slides right, out from under the text.
                  right:
                      -16 - (360 - constraints.maxWidth).clamp(0.0, 80.0) * 0.8,
                  top: 0,
                  bottom: 20,
                  child: _FadedMascot(),
                ),
                // The neon light around him, screened over the photo so its
                // black background lights up instead of blocking the glow.
                const Positioned(
                  right: -40,
                  top: -10,
                  width: 300,
                  height: 230,
                  child: IgnorePointer(
                    child: CustomPaint(painter: _ScreenGlow()),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 4,
                  // Clear of the card in his hand.
                  width: constraints.maxWidth * 0.46,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StreakChip(days: streakDays),
                      const SizedBox(height: 12),
                      if (goal == null) ...[
                        AppText(
                          'Санхүүгийн\nаялалаа\nэхлүүл!',
                          size: 22,
                          weight: FontWeight.w800,
                          color: Night.text,
                          height: 1.12,
                          letterSpacing: -0.6,
                        ),
                      ] else ...[
                        AppText(
                          'Зорилго',
                          size: 12,
                          weight: FontWeight.w600,
                          color: Night.text2,
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          goal,
                          size: 20,
                          weight: FontWeight.w800,
                          color: Night.text,
                          height: 1.15,
                          letterSpacing: -0.5,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            text: formatMnt(target - saved),
                            style: inter(
                              size: 13,
                              weight: FontWeight.w700,
                              color: AppColors.sky500,
                            ),
                            children: [
                              TextSpan(
                                text: ' үлдлээ',
                                style: inter(
                                  size: 13,
                                  weight: FontWeight.w500,
                                  color: Night.text2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: goal == null
                      ? const _StartRow()
                      : _GoalBar(progress: progress),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScreenGlow extends CustomPainter {
  const _ScreenGlow();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = const RadialGradient(
          center: Alignment(0.1, -0.1),
          radius: 0.5,
          colors: [Color(0x403EE6F0), Color(0x143EE6F0), Color(0x003EE6F0)],
          stops: [0.2, 0.62, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_ScreenGlow old) => false;
}

/// The mascot, fading into the black canvas at its left and bottom edges so
/// the photo has no visible frame.
class _FadedMascot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget fade(Alignment from, Alignment to, double stop, Widget child) =>
        ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (r) => LinearGradient(
            begin: from,
            end: to,
            colors: const [Color(0x00000000), Color(0xFF000000)],
            stops: [0, stop],
          ).createShader(r),
          child: child,
        );
    return fade(
      Alignment.bottomCenter,
      Alignment.topCenter,
      0.3,
      fade(
        Alignment.centerLeft,
        Alignment.centerRight,
        0.1,
        fade(
          Alignment.centerRight,
          Alignment.centerLeft,
          0.08,
          Image.asset(
            Mascots.teenCard,
            fit: BoxFit.fitHeight,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
      decoration: BoxDecoration(
        color: Night.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Night.amber.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LineIcon(LineGlyph.flame, size: 15, color: Night.amber),
          const SizedBox(width: 4),
          Flexible(
            child: AppText(
              '$days өдөр',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              size: 11,
              weight: FontWeight.w700,
              color: Night.amber,
            ),
          ),
        ],
      ),
    );
  }
}

/// A neon progress bar with its percentage, across the hero's foot.
class _GoalBar extends StatelessWidget {
  const _GoalBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
      decoration: BoxDecoration(
        color: Night.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Night.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 900),
              curve: appEmphasizedDecelerate,
              builder: (context, p, _) => LayoutBuilder(
                builder: (context, c) => Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Night.surface2,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Container(
                      height: 8,
                      width: c.maxWidth * p,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        gradient: LinearGradient(
                          colors: [AppColors.sky400, AppColors.sky500],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          AppText(
            '${(progress * 100).round()}%',
            size: 14,
            weight: FontWeight.w800,
            color: Night.text,
          ),
          const SizedBox(width: 6),
          const LineIcon(LineGlyph.chevronRight, size: 18, color: Night.text2),
        ],
      ),
    );
  }
}

class _StartRow extends StatelessWidget {
  const _StartRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: Night.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Night.line),
      ),
      child: Row(
        children: [
          LineIcon(LineGlyph.bolt, size: 18, color: AppColors.sky500),
          const SizedBox(width: 8),
          Expanded(
            child: AppText(
              'Эхний зорилгоо тавь',
              size: 13,
              weight: FontWeight.w700,
              color: Night.text,
            ),
          ),
          const LineIcon(LineGlyph.chevronRight, size: 18, color: Night.text2),
        ],
      ),
    );
  }
}
