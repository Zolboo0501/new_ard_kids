# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Ard KIDS: a Flutter mobile app (Android/iOS) for kids, a youth fintech product. The UI text is in **Mongolian (Cyrillic)**. Keep new user-facing strings and semantic labels in Mongolian, and match them exactly in tests. Routing uses `go_router`. There is no backend or state-management library. All data is mock data kept inside each screen, and API calls are `TODO`s.

## Commands

```bash
flutter pub get                                   # install deps
flutter run                                       # run on a connected device/simulator
flutter analyze                                   # lint (flutter_lints via analysis_options.yaml)
flutter test                                      # all tests
flutter test test/otp_and_friend_code_test.dart   # single file
flutter test --plain-name "Friend code: 6 digits confirm and open avatar picker"   # single test by name
flutter test test/screens_smoke_test.dart --plain-name "renders /transfer without errors"   # one screen's layout check
```

## Architecture

- `lib/main.dart`: `ArdKidsApp` builds `MaterialApp.router` with the router from `AppRoutes.createRouter()`.
- `lib/app/routes.dart`: `AppRoutes` holds every path (flat, top-level `GoRoute`s, auth at `/`) and `createRouter({initialLocation, extra})`.
  - Navigate with `context.push` to stack a screen, `context.pushReplacement` to swap it, and `context.go` to reset the stack (after sign-in, logout, skipping the parent link).
  - Pass data through `extra`: the phone number for `/otp`, a `TransferReceipt` for `/transfer/success`.
  - Only dialogs and bottom sheets still use `Navigator.pop` to return their result.
  - Transitions: every route is a `CustomTransitionPage` built by `lib/app/page_transitions.dart`. The default is `AppTransition.slide`; set `fade` (stack resets) or `rise` (task screens such as QR and the receipt) in `AppRoutes._transitions`. Reduced motion skips the animation.
  - When you add a screen, register it in `_builders`. `test/screens_smoke_test.dart` renders every path in `AppRoutes.paths`.
- `lib/features/<feature>/`: one file per screen, ported from the Stitch project "Kids Finance & Allowance App" (`projects/13411384382310318082`). Screens are `StatefulWidget`s with local state, and each file keeps its small subwidgets private.
  - Flow: `AuthScreen` → `OtpScreen` → `FriendCodeScreen` → `AvatarPickerScreen` → `ParentLinkScreen` → `HomeShell` (`/home`, or `/home/unlinked` when the parent link is skipped).
  - `home/home_shell.dart`: home and profile tabs with `FloatingNavBar`; the center QR button pushes `/qr`. Pushed sub-pages have no bottom nav.
  - Other folders: `transfer` (transfer, receipt, QR, money requests), `savings`, `accounts` (coin, rewards, stocks, card order, cart), `social`, `notifications`, `profile`, `onboarding`.
  - The `auth` screens simulate network calls with `Timer`s and cancel them in `dispose`.
  - Colors are compile-time `AppColors` constants, so `ThemeSettingsScreen` only saves the choice locally. Theme switching would need real theme plumbing.
- `lib/widgets/`: widgets shared across screens.
  - `ui.dart`: the shared kit: `AppCard`, `PrimaryButton`/`SoftButton`, `SubPageHeader`, `SegmentedTabs`, `StatusBadge`/`BadgeTone`, `AppTextField`, `MascotTile`, `ProgressTrack`, `formatMnt` (₮ formatting), `moneyStyle`, and `Mascots` (asset paths). Use these instead of re-styling.
  - `NumericKeypad` / `KeypadKey`: an on-screen digit pad used instead of the system keyboard. Each screen passes its own `KeypadStyle`.
  - `common.dart`: `CircleBackButton`, `BlinkingCursor` and `MascotImage`. `MascotImage` multiply-blends white-background mascot images into the surface color.
- `lib/theme/app_theme.dart`: the design tokens.
  - The screens are ports of a Google Stitch design ("Playful Youth Fintech"). `AppColors` holds Tailwind-style scales (sky/slate/emerald) and the Stitch Material 3 `ds*` tokens.
  - Use `AppColors` rather than hard-coding colors.
  - Build text styles with the `comfortaa(size:, weight:, color:)` helper, not raw `TextStyle`. Comfortaa is a variable font, so the helper also sets the `wght` font variation, which weight needs to render correctly.
- Assets: `assets/images/` (logo, mascots) and `assets/fonts/` (Comfortaa) are declared in `pubspec.yaml`.
  - To port another Stitch screen, fetch its HTML and screenshot with the Stitch MCP (`get_screen`).
  - Image URLs inside the Stitch HTML return 403, so take mascots from the project's image screens. Save them as ≤512px JPEGs in `assets/images/` and add them to `Mascots`.

## Testing notes

- Widget tests pump `MaterialApp.router(theme: buildAppTheme(), routerConfig: AppRoutes.createRouter(initialLocation: ..., extra: ...))`, one fresh router per test, so navigation works as in the app.
- `test/screens_smoke_test.dart` pumps every route at 390×844 and scrolls it. Any `RenderFlex` overflow or build error fails the test, so run it after layout changes.
- `test/flutter_test_config.dart` loads the real Comfortaa font for all tests. The default test font renders glyphs as wide squares and causes false overflow errors.
- Screens with a keypad set a phone-sized viewport (`tester.view.physicalSize` / `devicePixelRatio`, reset with `addTearDown`) so all keys fit on screen.
- Keypad digits can match other text, so tests tap `find.text(d).last`.
- Advance simulated delays and countdowns with `tester.pump(Duration)`.
