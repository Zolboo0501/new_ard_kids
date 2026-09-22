import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'common.dart';
import '../widgets/app_text.dart';
import 'value_switcher.dart';

/// Wraps a tap handler so it plays the app's tap haptic
/// ([HapticFeedback.selectionClick]) before running. `null` stays `null`, so
/// a disabled button stays disabled: `onTap: withHaptic(enabled ? save : null)`.
VoidCallback? withHaptic(VoidCallback? onTap) {
  if (onTap == null) return null;
  return () {
    HapticFeedback.selectionClick();
    onTap();
  };
}

/// Hides the on-screen keyboard by dropping focus from the current field.
/// Text fields pass it as `onTapOutside`, so tapping anywhere else on the
/// screen (a card, a button, empty space, or starting a scroll) closes it.
void dismissKeyboard([PointerDownEvent? _]) =>
    FocusManager.instance.primaryFocus?.unfocus();

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

/// Money numerals: Inter with tabular figures, so digits keep one width and
/// amounts line up in lists and don't shift while a balance counts up.
TextStyle moneyStyle({
  required double size,
  FontWeight weight = FontWeight.w700,
  Color color = AppColors.slate800,
  double? height,
  double? letterSpacing,
}) {
  return inter(
    size: size,
    weight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}

/// A balance amount in [moneyStyle], formatted with [formatMnt] plus two
/// decimal places: `BalanceText(1280000, size: 32)` → `₮1,280,000.00`.
/// Pass `decimals: false` for whole tugriks only (`₮1,280,000`).
///
/// The `₮` (and any `+`/`-` sign) is the same size as the digits; its
/// weight and color can differ with [currencyWeight] and [currencyColor].
/// The decimals (`.00`) are set smaller, at [decimalsScale] of [size], on
/// the same baseline and in [decimalsColor] grey, so the whole amount leads:
///
/// ```dart
/// BalanceText(
///   567930,
///   size: 34,
///   weight: FontWeight.w600,
///   letterSpacing: -0.8,
///   currencyColor: AppColors.slate700,
/// )
/// ```
///
/// With [animate], a change of [amount] rolls each digit from the old value
/// to the new one like an odometer instead of jumping (skipped when the
/// system asks for reduced motion). [animateFrom] also rolls the first
/// display up from that value, e.g. `animateFrom: 0` for a balance that
/// should roll in when it's revealed.
class BalanceText extends StatelessWidget {
  const BalanceText(
    this.amount, {
    super.key,
    required this.size,
    this.weight = FontWeight.w400,
    this.color = AppColors.slate800,
    this.sign = false,
    this.space = false,
    this.decimals = true,
    this.currencyWeight,
    this.currencyColor,
    this.height,
    this.letterSpacing,
    this.decoration,
    this.textAlign,
    this.maxLines = 1,
    this.overflow,
    this.semanticsLabel,
    this.animate = false,
    this.animateFrom,
  });

  final num amount;
  final double size;
  final FontWeight weight;
  final Color color;

  /// Forwarded to [formatMnt]: prefix `+` on positive amounts / a space
  /// after `₮`.
  final bool sign;
  final bool space;

  /// Appends the two-digit fraction (`.00`) after the whole amount.
  final bool decimals;

  /// Style of the `₮` span; `null` uses [weight] / [color].
  final FontWeight? currencyWeight;
  final Color? currencyColor;

  final double? height;
  final double? letterSpacing;

  /// e.g. [TextDecoration.lineThrough] for a declined amount.
  final TextDecoration? decoration;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  /// Counts to a new [amount] over [animationDuration] rather than jumping.
  final bool animate;

  /// Where the first display counts up from. Implies [animate].
  final num? animateFrom;

  /// How long the first digit takes to roll into place. All digits start
  /// together and each lands [_Odometer.stagger] after the one to its left,
  /// so the whole amount settles a little later.
  static const animationDuration = Duration(milliseconds: 550);

  /// The decimals' size relative to [size] (never smaller than 9px).
  static const decimalsScale = 0.6;

  /// The decimals' color, whatever [color] the amount is.
  static const decimalsColor = AppColors.slate400;

  @override
  Widget build(BuildContext context) {
    if ((!animate && animateFrom == null) ||
        MediaQuery.disableAnimationsOf(context)) {
      return _build(amount);
    }
    final text = _format(amount);
    final split = text.indexOf('₮') + 1;
    return _Odometer(
      amount: amount,
      prefix: text.substring(0, split),
      digits: text.substring(split),
      from: animateFrom == null ? null : _format(animateFrom!),
      fromAmount: animateFrom,
      prefixStyle: _currencyStyle,
      style: _digitStyle,
      decimalsStyle: _decimalsStyle,
      alignment: switch (textAlign) {
        TextAlign.center => MainAxisAlignment.center,
        TextAlign.right || TextAlign.end => MainAxisAlignment.end,
        _ => MainAxisAlignment.start,
      },
      // Screen readers hear the final amount, not each rolling digit.
      semanticsLabel: semanticsLabel ?? text,
    );
  }

  TextStyle get _currencyStyle => moneyStyle(
    size: size,
    weight: currencyWeight ?? weight,
    color: currencyColor ?? color,
    height: height,
  ).copyWith(decoration: decoration);

  TextStyle get _digitStyle => moneyStyle(
    size: size,
    weight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  ).copyWith(decoration: decoration);

  // Never below 9px, so the cents in small list amounts stay readable.
  TextStyle get _decimalsStyle => moneyStyle(
    size: (size * decimalsScale).clamp(9.0, size).toDouble(),
    weight: weight,
    color: decimalsColor,
    height: height,
    letterSpacing: letterSpacing,
  ).copyWith(decoration: decoration);

  Widget _build(num value) {
    final text = _format(value);
    final split = text.indexOf('₮') + 1;
    final point = decimals ? text.lastIndexOf('.') : -1;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, split), style: _currencyStyle),
          if (point < 0)
            TextSpan(text: text.substring(split))
          else ...[
            TextSpan(text: text.substring(split, point)),
            TextSpan(text: text.substring(point), style: _decimalsStyle),
          ],
        ],
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      style: _digitStyle,
    );
  }

  String _format(num value) => decimals
      ? _withDecimals(value)
      : formatMnt(value, sign: sign, space: space);

  /// Rounds to whole cents first so e.g. 9.999 reads `₮10.00`, and keeps the
  /// `-` for amounts between -1 and 0 that would round to a whole `0`.
  String _withDecimals(num value) {
    final cents = (value.abs() * 100).round();
    final whole = formatMnt(
      cents ~/ 100,
      sign: sign && value > 0,
      space: space,
    );
    final fraction = (cents % 100).toString().padLeft(2, '0');
    return '${value < 0 ? '-' : ''}$whole.$fraction';
  }
}

/// The rolling display behind an animated [BalanceText]: the sign and `₮`
/// stay put while every digit rolls on its own strip, left to right.
///
/// Slots are keyed by their distance from the right edge, so the ones and
/// tens keep rolling in place when the amount gains or loses a digit, and a
/// new leading digit rolls in from 0.
class _Odometer extends StatefulWidget {
  const _Odometer({
    required this.amount,
    required this.prefix,
    required this.digits,
    required this.from,
    required this.fromAmount,
    required this.prefixStyle,
    required this.style,
    required this.decimalsStyle,
    required this.alignment,
    required this.semanticsLabel,
  });

  final num amount;
  final String prefix;

  /// Everything after the `₮`: digits, grouping commas and the fraction.
  final String digits;

  /// The formatted value the first display rolls up from, or `null` to show
  /// [amount] straight away.
  final String? from;
  final num? fromAmount;
  final TextStyle prefixStyle;
  final TextStyle style;

  /// For the `.` and everything after it.
  final TextStyle decimalsStyle;
  final MainAxisAlignment alignment;
  final String semanticsLabel;

  /// How much later each digit lands than the one to its left.
  static const stagger = Duration(milliseconds: 25);

  @override
  State<_Odometer> createState() => _OdometerState();
}

class _OdometerState extends State<_Odometer> {
  /// Which way the digits roll: up while the amount grows, down as it
  /// shrinks, like a counter.
  late bool _up = (widget.fromAmount ?? widget.amount) <= widget.amount;

  @override
  void didUpdateWidget(_Odometer old) {
    super.didUpdateWidget(old);
    if (old.amount != widget.amount) _up = widget.amount > old.amount;
  }

  /// The digit in [text] at [fromRight] places from its end (`.` and `,`
  /// count as places), or `null` when that place isn't a digit.
  static int? _digitAt(String? text, int fromRight) {
    if (text == null) return null;
    final whole = text.substring(text.indexOf('₮') + 1);
    final i = whole.length - 1 - fromRight;
    if (i < 0) return 0;
    return int.tryParse(whole[i]);
  }

  /// Whether the first display has been built; after that, a digit place
  /// that newly appears (9,999 → 10,000) rolls in from 0.
  bool _built = false;

  @override
  Widget build(BuildContext context) {
    final chars = widget.digits.split('');
    final point = widget.digits.lastIndexOf('.');
    TextStyle styleAt(int i) =>
        point >= 0 && i >= point ? widget.decimalsStyle : widget.style;
    final from = _built ? '₮0' : widget.from;
    _built = true;
    return Semantics(
      label: widget.semanticsLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: widget.alignment,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(widget.prefix, style: widget.prefixStyle),
          for (final (i, c) in chars.indexed)
            // Only the whole amount rolls; the small grey decimals stay put.
            if ((point < 0 || i < point) ? int.tryParse(c) : null
                case final digit?)
              _RollingDigit(
                key: ValueKey(chars.length - 1 - i),
                digit: digit,
                from: _digitAt(from, chars.length - 1 - i),
                up: _up,
                delay: _Odometer.stagger * i,
                style: styleAt(i),
              )
            else
              Text(c, key: ValueKey(chars.length - 1 - i), style: styleAt(i)),
        ],
      ),
    );
  }
}

/// One odometer wheel. It lays out as an invisible copy of [digit], so it
/// has that glyph's width and baseline, and paints the wheel over it.
class _RollingDigit extends StatefulWidget {
  const _RollingDigit({
    super.key,
    required this.digit,
    required this.from,
    required this.up,
    required this.delay,
    required this.style,
  });

  final int digit;

  /// The digit the wheel starts on when it first appears; `null` starts at
  /// rest on [digit].
  final int? from;
  final bool up;
  final Duration delay;
  final TextStyle style;

  @override
  State<_RollingDigit> createState() => _RollingDigitState();
}

class _RollingDigitState extends State<_RollingDigit>
    with SingleTickerProviderStateMixin {
  /// Starts briskly and glides to a stop with no overshoot (ease-out
  /// quint), so the wheels slow down together instead of bouncing.
  static const _curve = Cubic(0.22, 1, 0.36, 1);

  /// How many faces every wheel passes when a balance rolls in, whatever
  /// its digit: a short, even settle rather than a spin.
  static const _revealSteps = 2;

  late final _controller = AnimationController(vsync: this)
    ..addListener(() => setState(() {}));

  // The wheel's position runs along an endless strip of 0–9; `_start` to
  // `_end` is the current roll.
  late double _start = widget.digit.toDouble();
  late double _end = widget.digit.toDouble();

  @override
  void initState() {
    super.initState();
    // Rolling in: every wheel travels the same short distance to its digit,
    // in the direction the amount is heading.
    if (widget.from != null) {
      final travel = widget.up ? -_revealSteps : _revealSteps;
      _start = (widget.digit + travel).toDouble();
      _controller
        ..duration = widget.delay + BalanceText.animationDuration
        ..forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(_RollingDigit old) {
    super.didUpdateWidget(old);
    if (old.digit != widget.digit) _rollTo(widget.digit);
  }

  // Every wheel starts at once; [_RollingDigit.delay] only lengthens its
  // roll, so the wheels land one after another with nothing sitting still
  // on a wrong digit in the meantime.
  double get _position =>
      _start + (_end - _start) * _curve.transform(_controller.value);

  /// Rolls from wherever the wheel is now to [digit], always in the
  /// odometer's direction, so e.g. 8 → 2 counting up passes 9 and 0.
  void _rollTo(int digit) {
    final now = _position;
    final base = now.floorToDouble() - (now.floor() % 10);
    var target = base + digit;
    if (widget.up) {
      while (target <= now) {
        target += 10;
      }
    } else {
      while (target >= now) {
        target -= 10;
      }
    }
    _start = now;
    _end = target;
    _controller
      ..duration = widget.delay + BalanceText.animationDuration
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = _position;
    final below = position.floor();
    final progress = position - below;
    return Stack(
      children: [
        // Sizes the slot and gives the row its baseline.
        Visibility.maintain(
          visible: false,
          child: Text('${widget.digit}', style: widget.style),
        ),
        Positioned.fill(
          child: progress == 0
              // At rest: just the digit, no mask or clip to paint.
              ? Text('${below % 10}', style: widget.style)
              // Rolling: faces fade out through soft top and bottom edges
              // rather than being cut off.
              : ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00000000),
                      Color(0xFF000000),
                      Color(0xFF000000),
                      Color(0x00000000),
                    ],
                    // Clear of a digit's own height (about 0.2–0.8 of the
                    // line), so a face that has landed isn't faded.
                    stops: [0, 0.18, 0.82, 1],
                  ).createShader(rect),
                  child: ClipRect(
                    child: LayoutBuilder(
                      builder: (context, box) {
                        final h = box.maxHeight;
                        Widget face(int n, double offset) =>
                            Transform.translate(
                              offset: Offset(0, offset * h),
                              child: Text('${n % 10}', style: widget.style),
                            );
                        // The digit rolling out moves up and away while the
                        // next one rises in from below.
                        return Stack(
                          children: [
                            face(below, -progress),
                            face(below + 1, 1 - progress),
                          ],
                        );
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

/// A balance the screen's eye button can hide. Hiding fades the balance out
/// quickly as the dots rise in; showing fades the dots out as the balance
/// fades in. Give [balance] `animateFrom: 0` and its digits roll in again
/// when revealed.
class HideableBalance extends StatelessWidget {
  const HideableBalance({
    super.key,
    required this.hidden,
    required this.balance,
  });

  final bool hidden;
  final BalanceText balance;

  @override
  Widget build(BuildContext context) {
    return ValueSwitcher(
      value: hidden,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 320),
      switchInCurve: appEmphasizedDecelerate,
      switchOutCurve: Curves.easeOut,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.centerLeft,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, animation, incoming) {
        // The outgoing face is gone within the first third, so it never
        // overlaps the digits rolling in.
        final opacity = incoming
            ? animation
            : CurvedAnimation(
                parent: animation,
                curve: const Interval(0.66, 1),
              );
        // A revealed balance rolls its own digits in, so it only fades;
        // the dots rise in when hiding.
        if (incoming && !hidden) {
          return FadeTransition(opacity: opacity, child: child);
        }
        return FadeTransition(
          opacity: opacity,
          child: SlideTransition(
            position: Tween(
              begin: Offset(0, incoming ? 0.35 : -0.35),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: hidden
          ? Text(
              '••••••••',
              key: const ValueKey(true),
              semanticsLabel: 'Үлдэгдэл нуусан',
              style: moneyStyle(
                size: balance.size,
                color: balance.color,
                letterSpacing: 4,
              ),
            )
          : KeyedSubtree(key: const ValueKey(false), child: balance),
    );
  }
}

/// The eye button that hides or shows an account's number and balance
/// together. The icon turns over as it switches.
class EyeToggle extends StatelessWidget {
  const EyeToggle({
    super.key,
    required this.hidden,
    required this.onTap,
    this.size = 16,
  });

  final bool hidden;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hidden ? 'Данс, үлдэгдэл харах' : 'Данс, үлдэгдэл нуух',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: withHaptic(onTap),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween(begin: 0.6, end: 1.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              hidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              key: ValueKey(hidden),
              size: size,
              color: AppColors.slate400,
            ),
          ),
        ),
      ),
    );
  }
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
      onTap: withHaptic(widget.onTap),
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
/// Small filter chip (filled when selected).
class FilterChipPill extends StatelessWidget {
  const FilterChipPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.mascot,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  /// A [Mascots] asset shown before the label, in place of an emoji.
  final String? mascot;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: withHaptic(onTap),
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
              if (mascot != null) ...[
                MascotIcon(mascot!, size: 18),
                const SizedBox(width: 5),
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
    this.mascot,
    this.padding = const EdgeInsets.fromLTRB(4, 4, 4, 8),
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final IconData? icon;

  /// A [Mascots] asset shown before the title, in place of an emoji.
  final String? mascot;
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
          if (mascot != null) ...[
            MascotIcon(mascot!, size: 22),
            const SizedBox(width: 6),
          ],
          Expanded(child: AppText(title, size: 14, weight: FontWeight.w700)),
          if (action != null)
            GestureDetector(
              onTap: withHaptic(onAction),
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
    // The whole box (prefix, suffix such as the clear button) counts as
    // part of the field, so tapping it doesn't close the keyboard.
    return TextFieldTapRegion(
      child: AnimatedContainer(
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
                size: 18,
                weight: FontWeight.w700,
                color: AppColors.slate500,
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                onTapOutside: dismissKeyboard,
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
                    inter(size: 14, weight: FontWeight.w700),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  hintText: widget.hint,
                  hintStyle: inter(size: 14, color: AppColors.slate400),
                ),
              ),
            ),
            if (widget.suffix != null) ...[
              const SizedBox(width: 8),
              widget.suffix!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A small animal sticker used in place of an emoji: the mascot inside a
/// white circle, so it reads the same on white, tinted and filled surfaces.
class MascotIcon extends StatelessWidget {
  const MascotIcon(this.asset, {super.key, this.size = 22, this.label = ''});

  final String asset;
  final double size;

  /// Semantic label; empty when the text next to it already says it all.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: MascotImage(
          asset: asset,
          size: size,
          background: Colors.white,
          semanticLabel: label,
        ),
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
    this.mascot,
  });

  final String text;
  final String? title;
  final IconData icon;
  final BadgeTone tone;

  /// A [Mascots] asset shown instead of [icon].
  final String? mascot;

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
          if (mascot != null)
            MascotIcon(mascot!, size: 24)
          else
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
              onTap: withHaptic(() => onSelected(amounts[i])),
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
///
/// [mascot] (a [Mascots] asset) shows an animal before the message, e.g. a
/// celebrating bear for a success.
void showAppSnack(BuildContext context, String message, {String? mascot}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.slate800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: mascot == null
            ? AppText(message, size: 13, color: Colors.white)
            : Row(
                children: [
                  MascotIcon(mascot, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppText(message, size: 13, color: Colors.white),
                  ),
                ],
              ),
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
      onChanged: (v) {
        HapticFeedback.selectionClick();
        onChanged(v);
      },
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
