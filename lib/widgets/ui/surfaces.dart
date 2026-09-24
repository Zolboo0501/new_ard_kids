/// Cards and buttons: the app's tappable surfaces.
library;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../app_text.dart';
import 'interaction.dart';

const _softShadow = [
  BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
];

/// Page background shared by the in-app screens. Follows the theme.
Color get kPageBackground => AppColors.pageBackground;

/// White rounded container with a thin sky border.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 20,
    this.color = Colors.white,
    this.borderColor,
    this.dashed = false,
    this.onTap,
    this.margin,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;

  /// Defaults to the theme accent (`AppColors.sky100`).
  final Color? borderColor;
  final bool dashed;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final borderColor = this.borderColor ?? AppColors.sky100;
    Widget box = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: dashed ? null : Border.all(color: borderColor),
        boxShadow: shadow ? _softShadow : null,
      ),
      child: child,
    );
    if (dashed) {
      box = CustomPaint(
        foregroundPainter: _DashedRRectPainter(
          color: borderColor,
          radius: radius,
        ),
        child: box,
      );
    }
    if (onTap == null) return box;
    return Pressable(onTap: onTap!, child: box);
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ).deflate(0.6),
      );
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}

/// Full-width pill call-to-action (sky gradient).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.leadingIcon,
    this.height = 52,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? leadingIcon;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final base = color ?? AppColors.sky500;
    return Semantics(
      button: true,
      enabled: enabled,
      child: Pressable(
        onTap: onPressed,
        scale: 0.98,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: enabled ? null : AppColors.slate200,
            gradient: enabled
                ? LinearGradient(
                    colors: color == null
                        ? [AppColors.sky500, AppColors.sky600]
                        : [base, base],
                  )
                : null,
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: base.withValues(alpha: 0.3),
                      offset: const Offset(0, 8),
                      blurRadius: 18,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(
                  leadingIcon,
                  size: 20,
                  color: enabled ? Colors.white : AppColors.slate400,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: AppText(
                  label,
                  size: 14,
                  weight: FontWeight.w700,
                  color: enabled ? Colors.white : AppColors.slate400,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  icon,
                  size: 20,
                  color: enabled ? Colors.white : AppColors.slate400,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Light pill button (sky tint) used for secondary actions.
class SoftButton extends StatelessWidget {
  const SoftButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 48,
    this.background,
    this.foreground,
    this.border,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  /// The colors default to the theme accent (`AppColors.sky50`/`sky600`/
  /// `sky100`). Pass [Colors.transparent] as [border] for no border.
  final Color? background;
  final Color? foreground;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    final foreground = this.foreground ?? AppColors.sky600;
    final border = this.border ?? AppColors.sky100;
    return Semantics(
      button: true,
      child: Pressable(
        onTap: onPressed,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: background ?? AppColors.sky50,
            borderRadius: BorderRadius.circular(999),
            border: border.a == 0 ? null : Border.all(color: border),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: AppText(
                  label,
                  size: 13,
                  weight: FontWeight.w700,
                  color: foreground,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round white icon button used in headers.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.label,
    this.badge = false,
    this.size = 40,
    this.color = AppColors.slate600,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String label;
  final bool badge;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Pressable(
        onTap: onPressed,
        scale: 0.92,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.sky100),
            boxShadow: _softShadow,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              if (badge)
                Positioned(
                  top: size * 0.24,
                  right: size * 0.24,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.sky500,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
