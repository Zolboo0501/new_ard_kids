# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Ard KIDS: a Flutter mobile app (Android/iOS) for kids, a youth fintech product. The UI text is in **Mongolian (Cyrillic)**. Keep new user-facing strings and semantic labels in Mongolian, and match them exactly in tests. Routing uses `go_router`. There is no backend or state-management library. All data is mock data, kept in each feature's `data/` folder or the screen's state, and API calls are `TODO`s.

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

- `lib/main.dart`: `ArdKidsApp` builds `MaterialApp.router` with the router from `AppRoutes.createRouter()`. `runApp` starts with `AppLoader` (`lib/app/app_loader.dart`). It shows `AppLoadingScreen` (the native splash's white background and logo, plus a spinner that only appears after 400 ms) while `ThemeStore`, `AvatarStore` and `BiometricStore` load, then fades to `ArdKidsApp`. The loading screen is drawn before the theme is known, so it uses only fixed colors.
- `lib/app/routes.dart`: `AppRoutes` holds every path and `createRouter({initialLocation, extra})`.
  - The signed-in bottom nav is a `StatefulShellRoute.indexedStack` with two branches, `/home` and `/profile`, rendered by `HomeShell`. Each tab keeps its own state. Switch tabs with `navigationShell.goBranch` or `context.go`.
  - Every other screen is a flat top-level `GoRoute` (sign-in at `/`). Pushing one covers the nav bar.
  - Some screen variants are query parameters: `AppRoutes.homeUnlinked` (`/home?linked=false`) and `avatarPickerEdit` (`?edit=true`, opened from Profile; it pops on save instead of continuing onboarding).
  - Navigate with `context.push` to stack a screen, `context.pushReplacement` to swap it, and `context.go` to reset the stack (after sign-in, logout, skipping the parent link).
  - Pass data through `extra`: the phone number for `/otp`, a `TransferReceipt` for `/transfer/success`.
  - Only dialogs and bottom sheets still use `Navigator.pop` to return their result.
  - Transitions: every route is a `CustomTransitionPage` built by `lib/app/page_transitions.dart`. The default is `AppTransition.slide`; set `fade` (stack resets) or `rise` (task screens such as QR and the receipt) in `AppRoutes._transitions`. Reduced motion skips the animation.
  - When you add a screen, register it in `_builders`. `test/screens_smoke_test.dart` renders every path in `AppRoutes.paths`, and `test/navigation_test.dart` covers tab switching and the pushes that cross the shell.
- `lib/app/accounts.dart`: `Accounts`, the kid's mock IBANs (valid mod-97), shared so every screen shows the same numbers; `maskIban`/`formatIban` for display.
- `lib/app/avatar.dart`: the companion the kid picks in the avatar picker (fox, bear, bunny, penguin).
  - `AppAvatar` holds each companion's own images (`pick`, `portrait`, `savings`, `stocks`, `rewards`) for Home and Profile, which listen to the `appAvatar` notifier. `AvatarStore` saves the choice in secure storage under `app_avatar`, and `main()` loads it before `runApp`, next to `ThemeStore`.
  - `Stickers` gives screen illustrations (`Stickers.piggy`, `Stickers.success`, …) from the chosen companion's sticker set, picked by `AppAvatar.stickerSet`. Use it for any picture that stands for the kid or an app action. Pictures of other people and of shop items stay on `Mascots`.
  - Like the theme accent, `Stickers.*` are getters, so they can't appear in `const` expressions or `static const` lists (use a `static get` list). `ArdKidsApp` rebuilds the whole tree when `appAvatar` changes, so open screens switch too.
- `lib/app/biometrics.dart`: biometric sign-in. `appBiometricLogin` is the Security screen toggle; `BiometricStore` saves it under `biometric_login` and `main()` loads it before `runApp`. `Biometrics.instance` wraps `local_auth` (tests swap in a fake). Turning the toggle on needs one successful scan. When it is on, `AuthScreen` shows a Face ID / Хурууны хээ button under Нэвтрэх and prompts by itself once per launch (`AuthScreen.biometricPrompted`, which tests reset). Android needs `FlutterFragmentActivity`, and iOS needs `NSFaceIDUsageDescription`.
- `lib/features/<feature>/`: the screens, ported from the Stitch project "Kids Finance & Allowance App" (`projects/13411384382310318082`). Every feature has the same layout:
  - `presentation/screens/`: one file per screen, holding only the screen widget, its `State` and any enum that is part of its API (`AuthMode`, `TransferMode`). Screens are `StatefulWidget`s with local state.
  - `presentation/widgets/`: one public widget per file (named after it, with a `super.key`). A helper used by only one widget stays private in that widget's file. Give generic names a screen prefix (`CardOrderSection`, `TransferSuccessRow`) so they don't clash with Flutter or each other.
  - `data/`: models, mock data and pure logic (`Invoice`/`mockInvoices`, `SavingsGoal`, `TransferReceipt`, `MoneyRequest`, `projectSavings`).
  - Flow: `AuthScreen` → `OtpScreen` → `FriendCodeScreen` → `AvatarPickerScreen` → `BiometricSetupScreen` (`/onboarding/biometric`, skipped when the phone has no biometric sensor) → `ParentLinkScreen` → `HomeShell` (`/home`, or `AppRoutes.homeUnlinked` when the parent link is skipped).
  - `home/presentation/screens/home_shell.dart` with `widgets/floating_nav_bar.dart`. The center QR button pushes `/qr`.
  - `home/data/invoice.dart` (`Invoice`, `mockInvoices`) and `home/presentation/widgets/invoice_card.dart`, shared by Home's Нэхэмжлэх tab (the newest three) and `InvoiceHistoryScreen` (`/invoices/history`, opened by Хуулга харах: every invoice with the date filter).
  - Other folders: `transfer` (transfer, receipt, QR, money requests), `savings`, `accounts` (coin, rewards, stocks, card order, cart), `social`, `notifications`, `profile`, `onboarding`.
  - The `auth` screens simulate network calls with `Timer`s and cancel them in `dispose`.
  - `ThemeSettingsScreen` switches the app theme (blue/pink) through `appThemeChoice`. `ThemeStore` (`lib/theme/theme_store.dart`) saves it in `flutter_secure_storage` under `app_theme`, and `main()` loads it before `runApp`. Tests fake the storage with `FlutterSecureStorage.setMockInitialValues`.
- `lib/widgets/`: widgets shared across screens.
  - `ui.dart`: the shared kit: `AppCard`, `PrimaryButton`/`SoftButton`, `SubPageHeader`, `StatusBadge`/`BadgeTone`, `AppTextField`, `MascotTile`, `ProgressTrack`, `formatMnt` (₮ formatting), `moneyStyle`, `Mascots` (asset paths), and the per-companion sticker paths `FoxStickers`/`BearStickers`/`RabbitStickers`/`PenguinStickers`. Use these instead of re-styling. `ui.dart` is a barrel: import it, but add new kit widgets to the matching file in `lib/widgets/ui/` (`money`, `surfaces`, `headers`, `chips`, `form_fields`, `mascots`, `feedback`, `interaction`).
  - `input_formatters.dart`: `ThousandsFormatter`, `IbanFormatter` and `DigitGroupFormatter` for amount and account-number fields.
  - `app_text.dart`: `AppText`, a `Text` that is always Inter. Use it instead of `Text(..., style: inter(...))`; reach for `inter()` directly only where a `TextStyle` is needed (inside a `TextSpan`, a `hintStyle`, a `TextField.style`).
  - `app_tabs.dart`: `AppTabs`/`AppTab`, the segmented control with a pill that slides between tabs, and `AppTabView` for its content pane (a Material 3 shared-axis transition: offset fades, directional slide, eased height). Used by the sign-in, home and QR screens. The behaviour is shared but the look is not: pass `AppTabsStyle.pill` (sign-in, the default), `.card` (home) or `.solid` (QR), each of which keeps that screen's original chrome. The scrollable filter chips in the request/notification lists are a different affordance and are not this.
  - `app_input.dart`: `AppInputShell`, `AppFieldLabel`, `AppFieldError`, `AppFieldTick`, plus `appInputStyle()`/`appInputDecoration()` — the form-field look, including the shake when a field newly becomes invalid.
  - `entrance.dart`: `Entrance`/`EntranceStagger`, the staggered fade-and-rise a screen plays once on open. Slices are built once in `initState` and disposed with the controller.
  - `value_switcher.dart`: an `AnimatedSwitcher` for content that changes with a value. Use it instead of keying children with `ValueKey(value)`, which throws "Duplicate keys found" on quick back-and-forth changes.
  - `date_range_filter.dart`: `DateRangeFilterBar`, the date filter above every transaction list (savings history, rewards, coin, invoice statement), and `DateRangeEmpty` for an empty range. The list owns a `DateTimeRange` that starts at `thisMonthRange()` and filters with `rangeContains`. The bar opens `showDateRangeSheet` (`date_range_sheet.dart`: presets Энэ сар / Сүүлийн 2 сар / Сүүлийн 3 сар, a `calendar_date_picker2` range calendar, and Цэвэрлэх back to this month). `TxItem` carries a `date`; its `when` label is derived from it.
  - `pin_code_sheet.dart`: `showPinCodeSheet`, the PIN bottom sheet that confirms a transfer.
  - `register_number_field.dart`: `RegisterNumberField`, the input for every editable Mongolian register number (sign-up, parent link). It has two letter boxes that open `showRegisterLetterSheet` (`register_letter_sheet.dart`, the 35-letter alphabet), then an 8-digit field. The screen owns the letters and the digits controller; `RegisterNumberField.validate` gives the shared error messages.
  - `NumericKeypad` / `KeypadKey`: an on-screen digit pad used instead of the system keyboard. Each screen passes its own `KeypadStyle`.
  - `common.dart`: `CircleBackButton`, `BlinkingCursor` and `MascotImage`. `MascotImage` multiply-blends white-background JPEG mascots into the surface color, and draws `.png` cutouts (the stickers) as they are.
- `lib/theme/app_theme.dart`: the design tokens.
  - The screens are ports of a Google Stitch design ("Playful Youth Fintech"). `AppColors` holds Tailwind-style scales (sky/slate/emerald) and the Stitch Material 3 `ds*` tokens.
  - Use `AppColors` rather than hard-coding colors.
  - Theming: `AppColors.sky*`, `dsPrimary`, `dsPrimaryContainer` and the page tints `pageBackground` (also `kPageBackground`) and `pageBackgroundMuted` (Profile) are the theme accent. They are getters that read the `AppPalette` for `appThemeChoice`, so they can't appear in `const` expressions, `static final` fields or default parameter values. Make the parameter nullable and fall back in `build` (`color ?? AppColors.sky500`). When the choice changes, `ArdKidsApp` marks every element dirty so the whole tree re-reads the palette. `SoftButton(border: Colors.transparent)` means no border.
  - Build text styles with the `inter(size:, weight:, color:)` helper, not raw `TextStyle`. Inter is a variable font, so the helper also sets the `wght` font variation, which weight needs to render correctly, and an `opsz` that follows the size. Use `moneyStyle()` for amounts and account numbers (Inter with tabular figures).
- Assets: `assets/images/` (logo, mascots) and `assets/fonts/` (Inter) are declared in `pubspec.yaml`.
  - To port another Stitch screen, fetch its HTML and screenshot with the Stitch MCP (`get_screen`).
  - Image URLs inside the Stitch HTML return 403, so take mascots from the project's image screens. Save them as ≤512px JPEGs in `assets/images/` and add them to `Mascots`.
  - Companion stickers are transparent ≤512px PNGs in `assets/images/<set>/<set>_<name>.png` (`fox`, `bear`, `rabbit`, `penguin`), cut from sticker sheets. Every set has the same 23 names that `Stickers` resolves, plus 14 more from a second sheet (games, travel, sports, lesson, art, payment, love, siblings, study, qr, books, snack, dad, mom) and `lock` (holding a phone, for PIN/security screens). The rabbit and bear have `invite` in place of `games`, so `Stickers.games` falls back to their `sports`. A new folder has to be listed in `pubspec.yaml`, and new assets need a full `flutter run` (a hot restart won't bundle them).
- Release: the app ships over-the-air patches with Shorebird (`shorebird.yaml`). The launcher icon and splash screen come from `flutter_launcher_icons.yaml` and `flutter_native_splash.yaml`.

## Testing notes

- Widget tests pump `MaterialApp.router(theme: buildAppTheme(), routerConfig: AppRoutes.createRouter(initialLocation: ..., extra: ...))`, one fresh router per test, so navigation works as in the app.
- `test/screens_smoke_test.dart` pumps every route at 390×844 and scrolls it. Any `RenderFlex` overflow or build error fails the test, so run it after layout changes.
- To check the current location in a test, read `router.state.uri`. `routerDelegate.currentConfiguration` ignores screens opened with `push`.
- The QR scanner animates forever, so use `pump(Duration)` there instead of `pumpAndSettle`.
- `test/flutter_test_config.dart` loads the real Inter font for all tests. The default test font renders glyphs as wide squares and causes false overflow errors.
- Screens with a keypad set a phone-sized viewport (`tester.view.physicalSize` / `devicePixelRatio`, reset with `addTearDown`) so all keys fit on screen.
- Keypad digits can match other text, so tests tap `find.text(d).last`.
- Advance simulated delays and countdowns with `tester.pump(Duration)`.
- `appThemeChoice` and `appAvatar` are global state that outlives a test. Tests that change them reset them (`AppThemeChoice.blue`, `AppAvatar.fox`) in `setUp`/`tearDown` (see `test/theme_switch_test.dart`, `test/avatar_picker_test.dart`).
- Don't hide layout-only widgets with `Opacity(opacity: 0)`: `test/home_shell_test.dart` reads the lowest `Opacity` on screen as the shell's fade. Use a transparent text color or similar instead.
