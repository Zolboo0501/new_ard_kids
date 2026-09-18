import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'common.dart';
import '../widgets/app_text.dart';

/// Formats [amount] as Mongolian tugrik with thousands separators:
/// `formatMnt(1280000)` → `₮1,280,000`.
String formatMnt(num amount, {bool sign = false, bool space = false}) {
  final negative = amount < 0;
  final digits = amount.abs().round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  final prefix = negative ? '-' : (sign ? '+' : '');
  return '$prefix₮${space ? ' ' : ''}$buf';
}

/// Balance-style numerals (the Stitch screens use Open Sans with tabular
/// figures for money; Comfortaa with tabular figures is the closest match).
TextStyle moneyStyle({
  required double size,
  FontWeight weight = FontWeight.w700,
  Color color = AppColors.slate800,
  double? letterSpacing,
}) {
  return comfortaa(
    size: size,
    weight: weight,
    color: color,
    letterSpacing: letterSpacing,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}

const _softShadow = [
  BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
];

/// Page background shared by the in-app screens.
const kPageBackground = Color(0xFFF5F8FE);

/// White rounded container with a thin sky border.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 20,
    this.color = Colors.white,
    this.borderColor = AppColors.sky100,
    this.dashed = false,
    this.onTap,
    this.margin,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color? borderColor;
  final bool dashed;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    Widget box = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null || dashed
            ? null
            : Border.all(color: borderColor!),
        boxShadow: shadow ? _softShadow : null,
      ),
      child: child,
    );
    if (dashed && borderColor != null) {
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

/// Scales its child down slightly while pressed.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onTap,
    required this.child,
    this.scale = 0.97,
  });

  final VoidCallback? onTap;
  final Widget child;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: const Duration(milliseconds: 110),
        child: widget.child,
      ),
    );
  }
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
                        ? const [AppColors.sky500, AppColors.sky600]
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
    this.background = AppColors.sky50,
    this.foreground = AppColors.sky600,
    this.border = AppColors.sky100,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final Color background;
  final Color foreground;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Pressable(
        onTap: onPressed,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999),
            border: border == null ? null : Border.all(color: border!),
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

/// Top bar for pushed screens: back button, centered title, optional action.
class SubPageHeader extends StatelessWidget implements PreferredSizeWidget {
  const SubPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onBack,
    this.background = kPageBackground,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onBack;
  final Color background;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background.withValues(alpha: 0.95),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.sky100.withValues(alpha: 0.6),
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: showBack
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: CircleBackButton(onPressed: onBack),
                      )
                    : null,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      title,
                      size: 16,
                      weight: FontWeight.w700,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      AppText(
                        subtitle!,
                        size: 11,
                        weight: FontWeight.w500,
                        color: AppColors.slate400,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 44,
                child: Align(alignment: Alignment.centerRight, child: trailing),
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

/// Segmented pill tabs on a tinted track.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
    this.dotOnActive = false,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final bool dotOnActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.sky100.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sky100),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == index,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: i == index ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: i == index ? _softShadow : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: AppText(
                            labels[i],
                            size: 13,
                            weight: i == index
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: i == index
                                ? AppColors.sky600
                                : AppColors.slate500,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (dotOnActive && i == index) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.sky500,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small filter chip (filled when selected).
class FilterChipPill extends StatelessWidget {
  const FilterChipPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.sky500 : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.sky100,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: selected ? Colors.white : AppColors.slate500,
                ),
                const SizedBox(width: 4),
              ],
              AppText(
                label,
                size: 11,
                weight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? Colors.white : AppColors.slate500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tinted status badge ("Идэвхтэй", "Хүлээгдэж буй", ...).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.sky,
    this.icon,
    this.dot = false,
  });

  final String label;
  final BadgeTone tone;
  final IconData? icon;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = tone.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 3),
          ],
          AppText(label, size: 10, weight: FontWeight.w700, color: fg),
        ],
      ),
    );
  }
}

enum BadgeTone {
  sky,
  emerald,
  amber,
  rose,
  slate;

  (Color, Color, Color) get colors => switch (this) {
    BadgeTone.sky => (AppColors.sky50, AppColors.sky600, AppColors.sky100),
    BadgeTone.emerald => (
      AppColors.emerald50,
      AppColors.emerald600,
      AppColors.emerald100,
    ),
    BadgeTone.amber => (
      AppColors.amber50,
      AppColors.amber600,
      AppColors.amber200,
    ),
    BadgeTone.rose => (AppColors.rose50, AppColors.rose600, AppColors.rose100),
    BadgeTone.slate => (
      AppColors.slate100,
      AppColors.slate500,
      AppColors.slate200,
    ),
  };
}

/// Section heading with an optional trailing action link.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.icon,
    this.padding = const EdgeInsets.fromLTRB(4, 4, 4, 8),
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final IconData? icon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.sky500),
            const SizedBox(width: 6),
          ],
          Expanded(child: AppText(title, size: 14, weight: FontWeight.w700)),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: AppText(
                action!,
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.sky600,
              ),
            ),
        ],
      ),
    );
  }
}

/// Small uppercase-ish field label.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text,
              size: 12,
              weight: FontWeight.w700,
              color: AppColors.slate500,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Rounded input box matching the Stitch forms.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.prefixText,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.textStyle,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? hint;
  final IconData? prefixIcon;
  final String? prefixText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextStyle? textStyle;
  final bool enabled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        color: widget.enabled ? Colors.white : AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focused ? AppColors.sky400 : AppColors.slate200,
          width: focused ? 1.6 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColors.sky400.withValues(alpha: 0.15),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          if (widget.prefixIcon != null) ...[
            Icon(
              widget.prefixIcon,
              size: 20,
              color: focused ? AppColors.sky500 : AppColors.slate400,
            ),
            const SizedBox(width: 10),
          ],
          if (widget.prefixText != null) ...[
            AppText(
              widget.prefixText!,
              size: 15,
              weight: FontWeight.w700,
              color: AppColors.slate500,
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              maxLines: widget.maxLines,
              cursorColor: AppColors.sky500,
              style:
                  widget.textStyle ??
                  comfortaa(size: 14, weight: FontWeight.w700),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                hintText: widget.hint,
                hintStyle: comfortaa(size: 14, color: AppColors.slate400),
              ),
            ),
          ),
          if (widget.suffix != null) ...[
            const SizedBox(width: 8),
            widget.suffix!,
          ],
        ],
      ),
    );
  }
}

/// Mascot tile: sticker image inside a rounded tinted square.
class MascotTile extends StatelessWidget {
  const MascotTile({
    super.key,
    required this.asset,
    this.size = 48,
    this.background = Colors.white,
    this.radius = 16,
    this.border,
    this.label = '',
  });

  final String asset;
  final double size;
  final Color background;
  final double radius;
  final Color? border;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.06),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: border == null ? null : Border.all(color: border!),
      ),
      child: MascotImage(
        asset: asset,
        size: size,
        background: background,
        semanticLabel: label,
      ),
    );
  }
}

/// Circular avatar with initials, used for people without a photo.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.background = AppColors.sky100,
    this.foreground = AppColors.sky700,
    this.square = false,
  });

  final String name;
  final double size;
  final Color background;
  final Color foreground;
  final bool square;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: square ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: square ? BorderRadius.circular(size * 0.32) : null,
      ),
      child: AppText(
        trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase(),
        size: size * 0.4,
        weight: FontWeight.w700,
        color: foreground,
      ),
    );
  }
}

/// Soft informational note with a leading icon.
class InfoNote extends StatelessWidget {
  const InfoNote({
    super.key,
    required this.text,
    this.icon = Icons.info_outline_rounded,
    this.tone = BadgeTone.sky,
    this.title,
  });

  final String text;
  final String? title;
  final IconData icon;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = tone.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: AppText(
                      title!,
                      size: 12,
                      weight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                AppText(
                  text,
                  size: 11,
                  weight: FontWeight.w500,
                  color: AppColors.slate600,
                  height: 1.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded progress track with a colored fill.
class ProgressTrack extends StatelessWidget {
  const ProgressTrack({
    super.key,
    required this.value,
    this.height = 8,
    this.color = AppColors.sky500,
    this.track = AppColors.slate100,
  });

  final double value;
  final double height;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: track)),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(height),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Row of quick amount chips (`+₮10,000`, ...).
class QuickAmountChips extends StatelessWidget {
  const QuickAmountChips({
    super.key,
    required this.amounts,
    required this.onSelected,
    this.selected,
    this.additive = true,
  });

  final List<int> amounts;
  final ValueChanged<int> onSelected;
  final int? selected;
  final bool additive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < amounts.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onTap: () => onSelected(amounts[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected == amounts[i]
                      ? AppColors.sky500
                      : AppColors.sky50,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected == amounts[i]
                        ? AppColors.sky500
                        : AppColors.sky100,
                  ),
                ),
                child: FittedBox(
                  child: AppText(
                    additive ? '+${_short(amounts[i])}' : formatMnt(amounts[i]),
                    size: 11,
                    weight: FontWeight.w700,
                    color: selected == amounts[i]
                        ? Colors.white
                        : AppColors.sky700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  static String _short(int v) => v >= 1000 && v % 1000 == 0
      ? '${formatMnt(v ~/ 1000).substring(1)}k'
      : formatMnt(v);
}

/// Shows a short confirmation snack bar in the app style.
void showAppSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.slate800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: AppText(message, size: 13, color: Colors.white),
      ),
    );
}

/// On/off switch styled for the app.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.sky500,
      activeThumbColor: Colors.white,
      inactiveTrackColor: AppColors.slate200,
      inactiveThumbColor: Colors.white,
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }
}

/// Mascot asset paths.
abstract final class Mascots {
  static const _d = 'assets/images';
  static const bearCard = '$_d/mascot_bear_card.jpg';
  static const foxPhone = '$_d/mascot_fox_phone.jpg';
  static const bunnyBattery = '$_d/mascot_bunny_battery.jpg';
  static const penguinChecklist = '$_d/mascot_penguin_checklist.jpg';
  static const owlBook = '$_d/mascot_owl_book.jpg';
  static const sleepingCat = '$_d/mascot_sleeping_cat.jpg';
  static const bearStar = '$_d/mascot_bear_star.jpg';
  static const puppyPiggy = '$_d/mascot_puppy_piggy.jpg';
  static const puppyGamepad = '$_d/mascot_puppy_gamepad.jpg';
  static const catHeart = '$_d/mascot_cat_heart.jpg';
  static const bearBooks = '$_d/mascot_bear_books.jpg';
  static const bearConfetti = '$_d/mascot_bear_confetti.jpg';
  static const owlAbacus = '$_d/mascot_owl_abacus.jpg';
  static const bearFamily = '$_d/mascot_bear_family.jpg';
  static const foxWave = '$_d/mascot_fox_wave.jpg';
  static const redPandaTrophy = '$_d/mascot_red_panda_trophy.jpg';
  static const pandaMilk = '$_d/mascot_panda_milk.jpg';
  static const pandaPiggy = '$_d/mascot_panda_piggy.jpg';
  static const hedgehogPiggy = '$_d/mascot_hedgehog_piggy.jpg';
  static const squirrelSafe = '$_d/mascot_squirrel_safe.jpg';
  static const bearShield = '$_d/mascot_bear_shield.jpg';
  static const studentCard = '$_d/student_card.jpg';
  static const otterInvest = '$_d/mascot_otter_invest.jpg';
  static const redPandaLetter = '$_d/mascot_red_panda_letter.jpg';
  static const foxBlocks = '$_d/mascot_fox_blocks.jpg';
  static const catNotes = '$_d/mascot_cat_notes.jpg';
  static const bunnyCoin = '$_d/mascot_bunny_coin.jpg';
  static const shieldBadge = '$_d/shield_badge.jpg';
  static const bearSitting = '$_d/mascot_bear_sitting.jpg';
  static const owlMedal = '$_d/mascot_owl_medal.jpg';
  static const bunnyTooth = '$_d/mascot_bunny_tooth.jpg';
  static const lambShield = '$_d/mascot_lamb_shield.jpg';
  static const penguinList = '$_d/mascot_penguin_list.jpg';
  static const bearFund = '$_d/mascot_bear_fund.jpg';
  static const bearHugCoin = '$_d/mascot_bear_hug_coin.jpg';
  static const foxJump = '$_d/mascot_fox_jump.jpg';
  static const fox = '$_d/mascot_fox.jpg';
  static const redPanda = '$_d/mascot_red_panda.jpg';
  static const pandaKey = '$_d/mascot_panda_key.png';
}
