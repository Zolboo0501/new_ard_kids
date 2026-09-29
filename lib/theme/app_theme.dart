import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

/// The accent a teen picks in "Өнгө ба харагдац". Each one has a light and
/// a dark scale (see [AppPalette]). Stored by name, so `blue` and `pink`
/// keep the choices saved before the accents were renamed.
enum AppThemeChoice { blue, violet, pink, mono }

/// Light or dark canvas. [system] follows the phone's setting.
enum AppBrightness { system, light, dark }

/// The accent scale a theme swaps in for the `sky*` and primary `ds*` tokens.
///
/// Every scale in the app runs from the canvas towards the ink: [c50]–[c200]
/// are tinted surfaces and borders that sit quietly on the page, [c500] is
/// the accent fill, and [c600]–[c900] are ever stronger accent inks for text
/// (darker on the light canvas, lighter on the dark one). Text on a [c500]
/// fill is [onAccent].
class AppPalette {
  const AppPalette({
    required this.c50,
    required this.c100,
    required this.c200,
    required this.c300,
    required this.c400,
    required this.c500,
    required this.c600,
    required this.c700,
    required this.c800,
    required this.c900,
    required this.onAccent,
  });

  final Color c50, c100, c200, c300, c400, c500, c600, c700, c800, c900;

  /// Text and icons printed on the accent fill.
  final Color onAccent;

  /// The accent scale for [choice] on the light or [dark] canvas.
  static AppPalette of(AppThemeChoice choice, {bool? dark}) {
    final d = dark ?? AppColors.isDark;
    return switch (choice) {
      AppThemeChoice.blue => d ? _blueDark : _blueLight,
      AppThemeChoice.violet => d ? _violetDark : _violetLight,
      AppThemeChoice.pink => d ? _pinkDark : _pinkLight,
      AppThemeChoice.mono => d ? _monoDark : _monoLight,
    };
  }

  static const _blueDark = AppPalette(
    c50: Color(0xFF0C2225),
    c100: Color(0xFF113035),
    c200: Color(0xFF1A474C),
    c300: Color(0xFF2A8A91),
    c400: Color(0xFF34CBD5),
    c500: Color(0xFF3EE6F0),
    c600: Color(0xFF5BEBF3),
    c700: Color(0xFF86F0F6),
    c800: Color(0xFFB2F6F9),
    c900: Color(0xFFD8FBFC),
    onAccent: Color(0xFF032A2E),
  );
  static const _blueLight = AppPalette(
    c50: Color(0xFFE6F4F5),
    c100: Color(0xFFCCE9EB),
    c200: Color(0xFF99D3D8),
    c300: Color(0xFF4DB3BC),
    c400: Color(0xFF1C929D),
    c500: Color(0xFF0A7882),
    c600: Color(0xFF086670),
    c700: Color(0xFF06535B),
    c800: Color(0xFF054147),
    c900: Color(0xFF032E33),
    onAccent: Color(0xFFFFFFFF),
  );

  static const _violetDark = AppPalette(
    c50: Color(0xFF1D1730),
    c100: Color(0xFF292043),
    c200: Color(0xFF3D2F66),
    c300: Color(0xFF6A55B0),
    c400: Color(0xFF8E74E8),
    c500: Color(0xFFA78BFA),
    c600: Color(0xFFB9A2FB),
    c700: Color(0xFFCBB9FC),
    c800: Color(0xFFDDD1FD),
    c900: Color(0xFFEEE8FE),
    onAccent: Color(0xFF1E1340),
  );
  static const _violetLight = AppPalette(
    c50: Color(0xFFF3F0FE),
    c100: Color(0xFFE6DFFD),
    c200: Color(0xFFCBBDFA),
    c300: Color(0xFFA48CF2),
    c400: Color(0xFF8466E9),
    c500: Color(0xFF6A45DC),
    c600: Color(0xFF5A36C4),
    c700: Color(0xFF4A2BA3),
    c800: Color(0xFF3A2180),
    c900: Color(0xFF29175C),
    onAccent: Color(0xFFFFFFFF),
  );

  static const _pinkDark = AppPalette(
    c50: Color(0xFF28111D),
    c100: Color(0xFF371727),
    c200: Color(0xFF55223D),
    c300: Color(0xFFA9487A),
    c400: Color(0xFFE668A4),
    c500: Color(0xFFFF7AB6),
    c600: Color(0xFFFF92C4),
    c700: Color(0xFFFFAAD1),
    c800: Color(0xFFFFC7E1),
    c900: Color(0xFFFFE2EF),
    onAccent: Color(0xFF3A0A22),
  );
  static const _pinkLight = AppPalette(
    c50: Color(0xFFFCEBF2),
    c100: Color(0xFFF9D5E5),
    c200: Color(0xFFF2A9C9),
    c300: Color(0xFFE873A6),
    c400: Color(0xFFD94585),
    c500: Color(0xFFC2185B),
    c600: Color(0xFFA5134D),
    c700: Color(0xFF86103F),
    c800: Color(0xFF680C31),
    c900: Color(0xFF4A0823),
    onAccent: Color(0xFFFFFFFF),
  );

  /// Graphite: the ink itself is the accent. White on the dark canvas,
  /// near-black on the light one.
  static const _monoDark = AppPalette(
    c50: Color(0xFF1B1D21),
    c100: Color(0xFF24262B),
    c200: Color(0xFF33363C),
    c300: Color(0xFF5A5E67),
    c400: Color(0xFFA9ADB5),
    c500: Color(0xFFF2F3F5),
    c600: Color(0xFFFFFFFF),
    c700: Color(0xFFFFFFFF),
    c800: Color(0xFFFFFFFF),
    c900: Color(0xFFFFFFFF),
    onAccent: Color(0xFF0B0C0E),
  );
  static const _monoLight = AppPalette(
    c50: Color(0xFFEEEFF2),
    c100: Color(0xFFE2E4E8),
    c200: Color(0xFFC9CCD3),
    c300: Color(0xFF9A9FA9),
    c400: Color(0xFF4A4F59),
    c500: Color(0xFF111317),
    c600: Color(0xFF0B0C0E),
    c700: Color(0xFF0B0C0E),
    c800: Color(0xFF0B0C0E),
    c900: Color(0xFF0B0C0E),
    onAccent: Color(0xFFFFFFFF),
  );
}

/// The active accent. `ArdKidsApp` rebuilds the whole tree when it changes,
/// so every `AppColors` read picks up the new palette.
final appThemeChoice = ValueNotifier(AppThemeChoice.blue);

/// The active canvas. Like [appThemeChoice], a change rebuilds everything.
final appBrightness = ValueNotifier(AppBrightness.system);

/// Everything in [AppColors] that is not the accent: canvas, surfaces,
/// neutral inks and the semantic scales, once per canvas.
class _Scheme {
  const _Scheme({
    required this.surface,
    required this.card,
    required this.onBright,
    required this.shadow,
    required this.slate,
    required this.emerald,
    required this.amber,
    required this.orange50,
    required this.rose,
    required this.indigo,
    required this.violet,
    required this.pink,
    required this.lime,
  });

  final Color surface, card, onBright, shadow, orange50;

  /// 50, 100, …, 900.
  final List<Color> slate;

  /// 50, 100, 200, 300, 400, 500, 600, 700, 800, 950.
  final List<Color> emerald;

  /// 50, 100, 200, 400, 500, 600, 700, 800.
  final List<Color> amber;

  /// 50, 100, 400, 500, 600.
  final List<Color> rose;

  /// 50, 100, 500.
  final List<Color> indigo, violet;

  /// 50, 100, 400, 500.
  final List<Color> pink;

  /// 50, 500.
  final List<Color> lime;

  static const dark = _Scheme(
    surface: Color(0xFF050607),
    card: Color(0xFF121316),
    onBright: Color(0xFF050607),
    shadow: Color(0x80000000),
    slate: [
      Color(0xFF1B1D21),
      Color(0xFF212328),
      Color(0xFF26282D),
      Color(0xFF454952),
      Color(0xFF7B808A),
      Color(0xFF9EA3AD),
      Color(0xFFB9BDC5),
      Color(0xFFD5D8DE),
      Color(0xFFEDEEF1),
      Color(0xFFFFFFFF),
    ],
    emerald: [
      Color(0xFF0D261C),
      Color(0xFF123626),
      Color(0xFF1B523A),
      Color(0xFF3FBF83),
      Color(0xFF4ADE9A),
      Color(0xFF4ADE9A),
      Color(0xFF5FE6A6),
      Color(0xFF86EDBC),
      Color(0xFFB0F4D3),
      Color(0xFFD9FAEA),
    ],
    amber: [
      Color(0xFF29200F),
      Color(0xFF382B12),
      Color(0xFF55411A),
      Color(0xFFFFC46B),
      Color(0xFFFFC46B),
      Color(0xFFFFCB7E),
      Color(0xFFFFD699),
      Color(0xFFFFE2B8),
    ],
    orange50: Color(0xFF2A1B10),
    rose: [
      Color(0xFF2B1215),
      Color(0xFF3B171C),
      Color(0xFFFF7B7B),
      Color(0xFFFF7B7B),
      Color(0xFFFF9090),
    ],
    indigo: [Color(0xFF181A31), Color(0xFF222549), Color(0xFF8E96FF)],
    violet: [Color(0xFF1D1730), Color(0xFF292043), Color(0xFFA78BFA)],
    pink: [
      Color(0xFF28111D),
      Color(0xFF371727),
      Color(0xFFFF7AB6),
      Color(0xFFFF7AB6),
    ],
    lime: [Color(0xFF1A2410), Color(0xFFA3E635)],
  );

  static const light = _Scheme(
    surface: Color(0xFFF5F6F8),
    card: Color(0xFFFFFFFF),
    onBright: Color(0xFFFFFFFF),
    shadow: Color(0x140B0C0E),
    slate: [
      Color(0xFFF1F2F5),
      Color(0xFFE9EBEF),
      Color(0xFFE1E3E8),
      Color(0xFFC3C7CF),
      Color(0xFF6A707D),
      Color(0xFF5B616D),
      Color(0xFF454A55),
      Color(0xFF30343C),
      Color(0xFF1C1F25),
      Color(0xFF0C0D10),
    ],
    emerald: [
      Color(0xFFE9F6EF),
      Color(0xFFD3EFE1),
      Color(0xFFA6DDC2),
      Color(0xFF5CC293),
      Color(0xFF1FA36A),
      Color(0xFF0C7F4E),
      Color(0xFF0B7349),
      Color(0xFF096040),
      Color(0xFF074D33),
      Color(0xFF043321),
    ],
    amber: [
      Color(0xFFFDF5E7),
      Color(0xFFFBEACB),
      Color(0xFFF2D196),
      Color(0xFFC77F06),
      Color(0xFFA35F00),
      Color(0xFF9A5B00),
      Color(0xFF7C4A00),
      Color(0xFF5E3800),
    ],
    orange50: Color(0xFFFDF1E8),
    rose: [
      Color(0xFFFDECEC),
      Color(0xFFFAD7D7),
      Color(0xFFE5484D),
      Color(0xFFCF2A32),
      Color(0xFFB4232A),
    ],
    indigo: [Color(0xFFEEF0FF), Color(0xFFDEE1FF), Color(0xFF4F55E0)],
    violet: [Color(0xFFF3F0FE), Color(0xFFE6DFFD), Color(0xFF6A45DC)],
    pink: [
      Color(0xFFFCEBF2),
      Color(0xFFF9D5E5),
      Color(0xFFD94585),
      Color(0xFFC2185B),
    ],
    lime: [Color(0xFFEFF6E2), Color(0xFF4D7C0F)],
  );
}

/// The app's colour tokens, for both canvases.
///
/// The names come from the original Stitch design (Tailwind sky / slate /
/// emerald scales), but every scale runs from the canvas to the ink:
/// `*50`–`*200` are quiet surfaces, tints and borders, the middle steps are
/// fills, and the high steps are inks for text. So `slate50` is a raised
/// surface, `slate500` secondary text and `slate900` the primary text, on
/// the light and the dark canvas alike. Cards are [card]; text on an
/// accent fill is [onAccent], on an emerald/amber/rose fill [onBright].
///
/// Every token follows [appBrightness] and `sky*` also [appThemeChoice], so
/// they are getters and can't be used in `const` expressions, `static
/// final` fields or default parameter values.
abstract final class AppColors {
  /// Whether the dark canvas is showing.
  static bool get isDark => switch (appBrightness.value) {
    AppBrightness.light => false,
    AppBrightness.dark => true,
    AppBrightness.system =>
      PlatformDispatcher.instance.platformBrightness == Brightness.dark,
  };

  static _Scheme get _s => isDark ? _Scheme.dark : _Scheme.light;

  /// The canvas, card and line of either mode, whichever is showing. For
  /// previews of a mode, such as the tiles in "Харагдац".
  static ({Color surface, Color card, Color line, Color text}) modePreview(
    bool dark,
  ) {
    final s = dark ? _Scheme.dark : _Scheme.light;
    return (
      surface: s.surface,
      card: s.card,
      line: s.slate[2],
      text: s.slate[9],
    );
  }

  static AppPalette get _p => AppPalette.of(appThemeChoice.value);

  /// The page canvas.
  static Color get surface => _s.surface;

  /// A card or sheet on the canvas.
  static Color get card => _s.card;

  /// Dividers and hairline borders.
  static Color get line => _s.slate[2];

  /// The one drop shadow the app uses, under floating chrome.
  static Color get shadow => _s.shadow;

  /// Text and icons on the accent fill (`sky500`/`sky600`).
  static Color get onAccent => _p.onAccent;

  /// Text and icons on a semantic fill (emerald, amber, rose 500).
  static Color get onBright => _s.onBright;

  // Material 3 tokens generated by Stitch for the design system.
  static Color get dsPrimary => _p.c500;
  static Color get dsPrimaryContainer => _p.c500;
  static Color get dsSurface => _s.surface;
  static Color get dsSurfaceContainerLow => _s.card;
  static Color get dsSurfaceContainerHigh => _s.slate[0];
  static Color get dsOnSurface => _s.slate[9];
  static Color get dsOnSurfaceVariant => _s.slate[5];
  static Color get dsOutlineVariant => _s.slate[2];

  static Color get pageBackground => _s.surface;
  static Color get pageBackgroundMuted => _s.surface;

  static Color get sky50 => _p.c50;
  static Color get sky100 => _p.c100;
  static Color get sky200 => _p.c200;
  static Color get sky300 => _p.c300;
  static Color get sky400 => _p.c400;
  static Color get sky500 => _p.c500;
  static Color get sky600 => _p.c600;
  static Color get sky700 => _p.c700;
  static Color get sky800 => _p.c800;
  static Color get sky900 => _p.c900;

  // Neutrals: surfaces and lines at the low end, text at the high end.
  static Color get slate50 => _s.slate[0];
  static Color get slate100 => _s.slate[1];
  static Color get slate200 => _s.slate[2];
  static Color get slate300 => _s.slate[3];
  static Color get slate400 => _s.slate[4];
  static Color get slate500 => _s.slate[5];
  static Color get slate600 => _s.slate[6];
  static Color get slate700 => _s.slate[7];
  static Color get slate800 => _s.slate[8];
  static Color get slate900 => _s.slate[9];

  static Color get emerald50 => _s.emerald[0];
  static Color get emerald100 => _s.emerald[1];
  static Color get emerald200 => _s.emerald[2];
  static Color get emerald300 => _s.emerald[3];
  static Color get emerald400 => _s.emerald[4];
  static Color get emerald500 => _s.emerald[5];
  static Color get emerald600 => _s.emerald[6];
  static Color get emerald700 => _s.emerald[7];
  static Color get emerald800 => _s.emerald[8];
  static Color get emerald950 => _s.emerald[9];

  static Color get amber50 => _s.amber[0];
  static Color get amber100 => _s.amber[1];
  static Color get amber200 => _s.amber[2];
  static Color get amber400 => _s.amber[3];
  static Color get amber500 => _s.amber[4];
  static Color get amber600 => _s.amber[5];
  static Color get amber700 => _s.amber[6];
  static Color get amber800 => _s.amber[7];

  static Color get orange50 => _s.orange50;

  static Color get rose50 => _s.rose[0];
  static Color get rose100 => _s.rose[1];
  static Color get rose400 => _s.rose[2];
  static Color get rose500 => _s.rose[3];
  static Color get rose600 => _s.rose[4];

  static Color get indigo50 => _s.indigo[0];
  static Color get indigo100 => _s.indigo[1];
  static Color get indigo500 => _s.indigo[2];
  static Color get violet50 => _s.violet[0];
  static Color get violet100 => _s.violet[1];
  static Color get violet500 => _s.violet[2];
  static Color get pink50 => _s.pink[0];
  static Color get pink100 => _s.pink[1];
  static Color get pink400 => _s.pink[2];
  static Color get pink500 => _s.pink[3];
  static Color get lime50 => _s.lime[0];
  static Color get lime500 => _s.lime[1];
}

/// Motion tokens. Material 3 "emphasized" easing starts slowly and settles
/// over a long tail, which reads as smoother than [Curves.easeOutCubic] for
/// anything moving a meaningful distance; the accelerate pair is its
/// counterpart for exits.
const appEmphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1);
const appEmphasizedAccelerate = Cubic(0.3, 0, 0.8, 0.15);

/// Inter ships as a variable font, so weight is applied through the `wght`
/// axis as well as [FontWeight] to render correctly on every platform. Its
/// `opsz` axis (14–32) follows the font size, so small labels get the open
/// text cut and balances the tighter display cut.
TextStyle inter({
  required double size,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    fontWeight: weight,
    fontVariations: [
      FontVariation.weight(weight.value.toDouble()),
      FontVariation.opticalSize(size.clamp(14, 32).toDouble()),
    ],
    color: color ?? AppColors.slate800,
    height: height,
    letterSpacing: letterSpacing,
  );
}

ThemeData buildAppTheme() {
  final brightness = AppColors.isDark ? Brightness.dark : Brightness.light;
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: brightness,
    scaffoldBackgroundColor: AppColors.surface,
    canvasColor: AppColors.surface,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.sky500,
      brightness: brightness,
      primary: AppColors.sky500,
      onPrimary: AppColors.onAccent,
      surface: AppColors.card,
      onSurface: AppColors.slate900,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.sky500,
      selectionColor: AppColors.sky500.withValues(alpha: 0.3),
      selectionHandleColor: AppColors.sky500,
    ),
    dividerColor: AppColors.line,
    // Sheets span the full width on iPad too, like the pages, instead of
    // Material's 640 cap.
    bottomSheetTheme: const BottomSheetThemeData(constraints: BoxConstraints()),
  );
}
