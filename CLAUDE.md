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
- `lib/app/routes.dart`: `AppRoutes` holds every path and `createRouter({initialLocation, extra})`.
  - The signed-in bottom nav is a `StatefulShellRoute.indexedStack` with two branches, `/home` and `/profile`, rendered by `HomeShell`. Each tab keeps its own state. Switch tabs with `navigationShell.goBranch` or `context.go`.
  - Every other screen is a flat top-level `GoRoute` (sign-in at `/`). Pushing one covers the nav bar.
  - Some screen variants are query parameters: `AppRoutes.homeUnlinked` (`/home?linked=false`) and `avatarPickerEdit` (`?edit=true`, opened from Profile; it pops on save instead of continuing onboarding).
  - Navigate with `context.push` to stack a screen, `context.pushReplacement` to swap it, and `context.go` to reset the stack (after sign-in, logout, skipping the parent link).
  - Pass data through `extra`: the phone number for `/otp`, a `TransferReceipt` for `/transfer/success`.
  - Only dialogs and bottom sheets still use `Navigator.pop` to return their result.
  - Transitions: every route is a `CustomTransitionPage` built by `lib/app/page_transitions.dart`. The default is `AppTransition.slide`; set `fade` (stack resets) or `rise` (task screens such as QR and the receipt) in `AppRoutes._transitions`. Reduced motion skips the animation.
  - When you add a screen, register it in `_builders`. `test/screens_smoke_test.dart` renders every path in `AppRoutes.paths`, and `test/navigation_test.dart` covers tab switching and the pushes that cross the shell.
- `lib/features/<feature>/`: one file per screen, ported from the Stitch project "Kids Finance & Allowance App" (`projects/13411384382310318082`). Screens are `StatefulWidget`s with local state, and each file keeps its small subwidgets private.
  - Flow: `AuthScreen` → `OtpScreen` → `FriendCodeScreen` → `AvatarPickerScreen` → `ParentLinkScreen` → `HomeShell` (`/home`, or `/home/unlinked` when the parent link is skipped).
  - `home/home_shell.dart`: the `FloatingNavBar` for the shell. The center QR button pushes `/qr`.
  - Other folders: `transfer` (transfer, receipt, QR, money requests), `savings`, `accounts` (coin, rewards, stocks, card order, cart), `social`, `notifications`, `profile`, `onboarding`.
  - The `auth` screens simulate network calls with `Timer`s and cancel them in `dispose`.
  - Colors are compile-time `AppColors` constants, so `ThemeSettingsScreen` only saves the choice locally. Theme switching would need real theme plumbing.
- `lib/widgets/`: widgets shared across screens.
  - `ui.dart`: the shared kit: `AppCard`, `PrimaryButton`/`SoftButton`, `SubPageHeader`, `StatusBadge`/`BadgeTone`, `AppTextField`, `MascotTile`, `ProgressTrack`, `formatMnt` (₮ formatting), `moneyStyle`, and `Mascots` (asset paths). Use these instead of re-styling.
  - `app_text.dart`: `AppText`, a `Text` that is always Inter. Use it instead of `Text(..., style: inter(...))`; reach for `inter()` directly only where a `TextStyle` is needed (inside a `TextSpan`, a `hintStyle`, a `TextField.style`).
  - `app_tabs.dart`: `AppTabs`/`AppTab`, the segmented control with a pill that slides between tabs, and `AppTabView` for its content pane (a Material 3 shared-axis transition: offset fades, directional slide, eased height). Used by the sign-in, home and QR screens. The behaviour is shared but the look is not: pass `AppTabsStyle.pill` (sign-in, the default), `.card` (home) or `.solid` (QR), each of which keeps that screen's original chrome. The scrollable filter chips in the request/notification lists are a different affordance and are not this.
  - `app_input.dart`: `AppInputShell`, `AppFieldLabel`, `AppFieldError`, `AppFieldTick`, plus `appInputStyle()`/`appInputDecoration()` — the form-field look, including the shake when a field newly becomes invalid.
  - `entrance.dart`: `Entrance`/`EntranceStagger`, the staggered fade-and-rise a screen plays once on open. Slices are built once in `initState` and disposed with the controller.
  - `NumericKeypad` / `KeypadKey`: an on-screen digit pad used instead of the system keyboard. Each screen passes its own `KeypadStyle`.
  - `common.dart`: `CircleBackButton`, `BlinkingCursor` and `MascotImage`. `MascotImage` multiply-blends white-background mascot images into the surface color.
- `lib/theme/app_theme.dart`: the design tokens.
  - The screens are ports of a Google Stitch design ("Playful Youth Fintech"). `AppColors` holds Tailwind-style scales (sky/slate/emerald) and the Stitch Material 3 `ds*` tokens.
  - Use `AppColors` rather than hard-coding colors.
  - Build text styles with the `inter(size:, weight:, color:)` helper, not raw `TextStyle`. Inter is a variable font, so the helper also sets the `wght` font variation, which weight needs to render correctly, and an `opsz` that follows the size. Use `moneyStyle()` for amounts and account numbers (Inter with tabular figures).
- Assets: `assets/images/` (logo, mascots) and `assets/fonts/` (Inter) are declared in `pubspec.yaml`.
  - To port another Stitch screen, fetch its HTML and screenshot with the Stitch MCP (`get_screen`).
  - Image URLs inside the Stitch HTML return 403, so take mascots from the project's image screens. Save them as ≤512px JPEGs in `assets/images/` and add them to `Mascots`.

## Testing notes

- Widget tests pump `MaterialApp.router(theme: buildAppTheme(), routerConfig: AppRoutes.createRouter(initialLocation: ..., extra: ...))`, one fresh router per test, so navigation works as in the app.
- `test/screens_smoke_test.dart` pumps every route at 390×844 and scrolls it. Any `RenderFlex` overflow or build error fails the test, so run it after layout changes.
- To check the current location in a test, read `router.state.uri`. `routerDelegate.currentConfiguration` ignores screens opened with `push`.
- The QR scanner animates forever, so use `pump(Duration)` there instead of `pumpAndSettle`.
- `test/flutter_test_config.dart` loads the real Inter font for all tests. The default test font renders glyphs as wide squares and causes false overflow errors.
- Screens with a keypad set a phone-sized viewport (`tester.view.physicalSize` / `devicePixelRatio`, reset with `addTearDown`) so all keys fit on screen.
- Keypad digits can match other text, so tests tap `find.text(d).last`.
- Advance simulated delays and countdowns with `tester.pump(Duration)`.
