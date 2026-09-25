/// Tugrik formatting and the balance widgets built on it.
library;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../value_switcher.dart';
import 'interaction.dart';

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
/// Pass `decimals: false` for whole tugriks only (`₮1,280,000`); an amount
/// with cents (`20000.94`) still shows them, so they're never rounded away.
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
    this.decimals = false,
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

  /// Appends the two-digit fraction (`.00`) after the whole amount. Only
  /// honoured as `false` for whole amounts: cents are always shown.
  final bool decimals;

  /// Whether [value] has cents once rounded to them, e.g. `20000.94` but not
  /// `20000` or `9.999` (which reads `₮10.00`).
  static bool hasCents(num value) => (value.abs() * 100).round() % 100 != 0;

  bool get _decimals => decimals || hasCents(amount);

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
    final point = _decimals ? text.lastIndexOf('.') : -1;
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

  String _format(num value) => _decimals
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
    this.highlighted = false,
  });

  final bool hidden;
  final VoidCallback onTap;
  final double size;

  /// Draws the eye in the theme accent on a tinted circle, for where it's
  /// the card's main control (the Home balance card).
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hidden ? 'Данс, үлдэгдэл харах' : 'Данс, үлдэгдэл нуух',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: withHaptic(onTap),
        child: Container(
          padding: EdgeInsets.all(highlighted ? 7 : 6),
          decoration: highlighted
              ? BoxDecoration(
                  color: AppColors.sky50,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.sky200),
                )
              : null,
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
              color: highlighted ? AppColors.sky600 : AppColors.slate400,
            ),
          ),
        ),
      ),
    );
  }
}
