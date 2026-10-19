import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/avatar.dart';
import '../app/sounds.dart';
import '../theme/app_theme.dart';

/// The avatar just picked from Profile, waiting for Home to show it with
/// [showAvatarReveal]. Home clears it once it has.
final pendingAvatarReveal = ValueNotifier<AppAvatar?>(null);

/// Pops [avatar] up, the whole character, in the middle of the screen, holds it a
/// moment and fades it away by itself, with a blast behind it and the pick
/// sound as it lands and soft haptics throughout. It doesn't take taps, so the screen
/// under it stays usable.
void showAvatarReveal(BuildContext context, AppAvatar avatar) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => AvatarReveal(
      avatar: avatar,
      onDone: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

/// The popup [showAvatarReveal] puts up: the whole character standing on
/// a soft accent glow.
class AvatarReveal extends StatefulWidget {
  const AvatarReveal({super.key, required this.avatar, required this.onDone});

  final AppAvatar avatar;
  final VoidCallback onDone;

  @override
  State<AvatarReveal> createState() => _AvatarRevealState();
}

class _AvatarRevealState extends State<AvatarReveal>
    with SingleTickerProviderStateMixin {
  static const _size = 260.0;

  /// The whole run: a short wait for the screen to arrive, the pop, the
  /// hold and the fade.
  late final AnimationController _run = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  late final Animation<double> _in = CurvedAnimation(
    parent: _run,
    curve: const Interval(0.14, 0.34, curve: Curves.easeOut),
  );
  late final Animation<double> _pop = Tween(begin: 0.4, end: 1.0).animate(
    CurvedAnimation(
      parent: _run,
      curve: const Interval(0.14, 0.4, curve: Curves.easeOutBack),
    ),
  );
  late final Animation<double> _out = CurvedAnimation(
    parent: _run,
    curve: const Interval(0.75, 1, curve: Curves.easeIn),
  );

  /// The burst behind the character as it lands (see [_BlastPainter]).
  late final Animation<double> _blast = CurvedAnimation(
    parent: _run,
    curve: const Interval(0.14, 0.56),
  );

  /// The confetti, laid out once so every frame draws the same pieces.
  static final List<_Piece> _pieces = () {
    final random = math.Random(7);
    const count = 26;
    return [
      for (var i = 0; i < count; i++)
        _Piece(
          angle: i / count * math.pi * 2 + random.nextDouble() * 0.3,
          distance: 120 + random.nextDouble() * 80,
          size: 4 + random.nextDouble() * 5,
          shape: i % 3,
          color: i % 6,
          spin: (random.nextDouble() - 0.5) * 10,
        ),
    ];
  }();

  @override
  void initState() {
    super.initState();
    _run.addListener(_onTick);
    _run.forward().whenComplete(widget.onDone);
  }

  /// A soft haptic pattern that runs from the pop to the fade: a tap as
  /// the character lands, two as it bounces, gentle heartbeats while it
  /// stands, thinning out as it fades. Points along [_run].
  static const _beats = [
    0.14, 0.20, 0.25, //
    0.38, 0.42, 0.54, 0.58, 0.70, 0.74, //
    0.82, 0.90, 0.97,
  ];
  int _beat = 0;

  void _onTick() {
    while (_beat < _beats.length && _run.value >= _beats[_beat]) {
      // The landing is a touch firmer and plays the pick sound; the rest
      // are the lightest tick.
      if (_beat == 0) {
        HapticFeedback.lightImpact();
        AppSounds.instance.play(AppSounds.pick);
      } else {
        HapticFeedback.selectionClick();
      }
      _beat++;
    }
  }

  @override
  void dispose() {
    _run.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _run,
          builder: (context, child) {
            final opacity = (_in.value * (1 - _out.value)).clamp(0.0, 1.0);
            // Reduced motion: only the fade.
            final scale = reduceMotion ? 1.0 : _pop.value + 0.08 * _out.value;
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Reduced motion: no burst.
                if (!reduceMotion)
                  CustomPaint(
                    size: const Size.square(_size * 1.6),
                    painter: _BlastPainter(
                      t: _blast.value,
                      pieces: _pieces,
                      colors: [
                        AppColors.sky400,
                        AppColors.rose400,
                        AppColors.violet500,
                        AppColors.emerald400,
                        AppColors.sky300,
                        AppColors.rose500,
                      ],
                    ),
                  ),
                Opacity(
                  opacity: opacity,
                  child: Transform.scale(scale: scale, child: child),
                ),
              ],
            );
          },
          child: SizedBox(
            width: _size,
            height: _size,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // A soft accent glow behind the character.
                Positioned(
                  bottom: _size * 0.08,
                  child: Container(
                    width: _size * 0.8,
                    height: _size * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.sky300.withValues(alpha: 0.55),
                          AppColors.sky300.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Image.asset(
                  widget.avatar.revealArt,
                  height: _size,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  semanticLabel: widget.avatar.name,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One confetti piece: where it flies, how big it is and how it turns.
class _Piece {
  const _Piece({
    required this.angle,
    required this.distance,
    required this.size,
    required this.shape,
    required this.color,
    required this.spin,
  });

  final double angle;
  final double distance;
  final double size;

  /// 0 a dot, 1 a confetti strip, 2 a diamond.
  final int shape;

  /// Index into the painter's colours.
  final int color;
  final double spin;
}

/// The blast behind the avatar, over [t] from 0 to 1: a flash at the
/// centre, two shockwave rings, short rays, and confetti flying out and
/// drifting down as it fades.
class _BlastPainter extends CustomPainter {
  const _BlastPainter({
    required this.t,
    required this.pieces,
    required this.colors,
  });

  final double t;
  final List<_Piece> pieces;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final c = size.center(Offset.zero);
    final out = Curves.easeOutCubic.transform(t);

    // The flash, gone within the first third.
    final flash = (1 - t / 0.3).clamp(0.0, 1.0);
    if (flash > 0) {
      canvas.drawCircle(
        c,
        50 + 70 * out,
        Paint()
          ..color = colors[0].withValues(alpha: 0.45 * flash)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    // Two shockwaves, the second a beat behind the first.
    for (final (delay, color) in [(0.0, colors[0]), (0.12, colors[1])]) {
      final r = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (r <= 0 || r >= 1) continue;
      final e = Curves.easeOutCubic.transform(r);
      canvas.drawCircle(
        c,
        60 + 150 * e,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 + 9 * (1 - e)
          ..color = color.withValues(alpha: 0.7 * (1 - r)),
      );
    }

    // Rays, shooting out and shrinking over the first half.
    final rays = (t / 0.5).clamp(0.0, 1.0);
    if (rays < 1) {
      final e = Curves.easeOutCubic.transform(rays);
      final paint = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4;
      for (var i = 0; i < 12; i++) {
        // Alternating the first two colours.
        paint.color = colors[i % 2].withValues(alpha: 1 - rays);
        final a = i / 12 * math.pi * 2 + math.pi / 12;
        final dir = Offset(math.cos(a), math.sin(a));
        final from = 70 + 90 * e;
        canvas.drawLine(
          c + dir * from,
          c + dir * (from + 36 * (1 - rays)),
          paint,
        );
      }
    }

    // Confetti: out fast, then a little gravity while it fades.
    final fade = t < 0.55 ? 1.0 : 1 - (t - 0.55) / 0.45;
    for (final p in pieces) {
      final pos =
          c +
          Offset(math.cos(p.angle), math.sin(p.angle)) * (p.distance * out) +
          Offset(0, 50 * t * t);
      final paint = Paint()
        ..color = colors[p.color % colors.length].withValues(alpha: fade);
      final s = p.size * (1 - 0.35 * t);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.angle + p.spin * t);
      switch (p.shape) {
        case 0:
          canvas.drawCircle(Offset.zero, s / 2, paint);
        case 1:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: s * 1.8, height: s),
              Radius.circular(s / 4),
            ),
            paint,
          );
        default:
          canvas.drawPath(
            Path()
              ..moveTo(0, -s)
              ..lineTo(s * 0.6, 0)
              ..lineTo(0, s)
              ..lineTo(-s * 0.6, 0)
              ..close(),
            paint,
          );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BlastPainter old) => old.t != t;
}
