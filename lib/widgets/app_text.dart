import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A [Text] that is always styled with Comfortaa.
///
/// Use this instead of `Text(..., style: comfortaa(...))` so screens never
/// reach for a raw [TextStyle]. The defaults match [comfortaa] exactly, so
/// swapping one for the other does not change how anything renders.
///
/// ```dart
/// const AppText('Найзаа нэмэх', size: 22, weight: FontWeight.w700)
/// ```
///
/// Reach for [comfortaa] directly only where a [TextStyle] is what is wanted
/// rather than a widget — inside a [TextSpan], an [InputDecoration.hintStyle]
/// or a [TextField.style].
class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    required this.size,
    this.weight = FontWeight.w400,
    this.color = AppColors.slate800,
    this.height,
    this.letterSpacing,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.semanticsLabel,
  });

  final String data;

  // Type: forwarded to [comfortaa].
  final double size;
  final FontWeight weight;
  final Color color;
  final double? height;
  final double? letterSpacing;

  // Applied on top of the Comfortaa style, for the few places that need them.
  final FontStyle? fontStyle;
  final TextDecoration? decoration;
  final Color? decorationColor;

  // Layout: forwarded to [Text].
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      semanticsLabel: semanticsLabel,
      style: _style,
    );
  }

  TextStyle get _style {
    final base = comfortaa(
      size: size,
      weight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
    if (fontStyle == null && decoration == null && decorationColor == null) {
      return base;
    }
    return base.copyWith(
      fontStyle: fontStyle,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }
}
