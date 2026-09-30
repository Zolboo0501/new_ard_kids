/// Cards and buttons: the app's tappable surfaces.
library;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../app_text.dart';
import '../avatar_card_art.dart';
import 'interaction.dart';

/// Page background shared by the in-app screens. Follows the theme.
Color get kPageBackground => AppColors.pageBackground;

/// A rounded card on the night canvas: flat [AppColors.card], no border
/// unless one is asked for (a dashed card always draws its outline).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 16,
    this.color,
    this.borderColor,
    this.dashed = false,
    this.onTap,
    this.margin,
    this.shadow = true,
    this.image,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;

  /// No border by default; a dashed card defaults to `AppColors.slate300`.
  final Color? borderColor;
  final bool dashed;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  /// Kept so existing callers still build; shadows don't read on the dark
  /// canvas, so cards are flat.
  final bool shadow;

  /// Art behind the content, clipped to the card's rounded shape.
  final DecorationImage? image;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        this.borderColor ?? (dashed ? AppColors.slate300 : null);
    Widget box = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        // Transparent on a character's card art (AvatarCardArt).
        color:
            color ??
            (AvatarCardArt.artUnder(context)
                ? Colors.transparent
                : AppColors.card),
        image: image,
        borderRadius: BorderRadius.circular(radius),
        border: dashed || borderColor == null
            ? null
            : Border.all(color: borderColor),
      ),
      child: child,
    );
    if (dashed) {
      box = CustomPaint(
        foregroundPainter: _DashedRRectPainter(
          color: borderColor!,
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

/// Full-width pill call-to-action: a solid accent fill with dark ink, like
/// Home's mint button. A custom [color] gets [AppColors.onBright] ink
/// unless [foreground] says otherwise.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.leadingIcon,
    this.height = 52,
    this.color,
    this.foreground,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? leadingIcon;
  final double height;
  final Color? color;

  /// The label and icon colour on an enabled button.
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final base = color ?? AppColors.sky500;
    final ink =
        foreground ?? (color == null ? AppColors.onAccent : AppColors.onBright);
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
            color: enabled ? base : AppColors.slate100,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(
                  leadingIcon,
                  size: 20,
                  color: enabled ? ink : AppColors.slate400,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: AppText(
                  label,
                  size: 14,
                  weight: FontWeight.w700,
                  color: enabled ? ink : AppColors.slate400,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 20, color: enabled ? ink : AppColors.slate400),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary pill button: a dark accent tint with accent ink.
class SoftButton extends StatelessWidget {
  const SoftButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.leading,
    this.height = 48,
    this.background,
    this.foreground,
    this.border,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Drawn in place of [icon] (e.g. a [LineIcon]).
  final Widget? leading;
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
              if (leading != null || icon != null) ...[
                leading ?? Icon(icon, size: 18, color: foreground),
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

/// Round raised icon button used in headers.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.label,
    this.badge = false,
    this.size = 40,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String label;
  final bool badge;
  final double size;
  final Color? color;

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
            color: AppColors.card,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20, color: color ?? AppColors.slate600),
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
                      border: Border.all(color: AppColors.card, width: 1.5),
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
