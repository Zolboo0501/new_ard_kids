import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../theme/theme_store.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/accent_card.dart';
import '../widgets/theme_mode_tile.dart';

/// "Миний өнгө": day / night / like-the-phone canvas and the accent colour. Every
/// choice applies at once and is saved, like the phone's own settings.
class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  // Words a child uses: day, night, and "like my phone" for the system
  // setting.
  static const _modes = [
    (AppBrightness.system, 'System'),
    (AppBrightness.light, 'Light'),
    (AppBrightness.dark, 'Dark'),
  ];

  static const _accents = [
    (AppThemeChoice.sky, 'Цэнхэр'),
    (AppThemeChoice.blue, 'Ногоон'),
    (AppThemeChoice.indigo, 'Нил хөх'),
    (AppThemeChoice.pink, 'Ягаан'),
    (AppThemeChoice.lime, 'Шар ногоон'),
    (AppThemeChoice.mono, 'Хар цагаан'),
  ];

  void _setMode(AppBrightness mode) {
    if (appBrightness.value == mode) return;
    appBrightness.value = mode;
    ThemeStore.saveBrightness(mode);
  }

  void _setAccent(AppThemeChoice choice) {
    if (appThemeChoice.value == choice) return;
    appThemeChoice.value = choice;
    ThemeStore.save(choice);
  }

  Widget _heading(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
    child: AppText(title, size: 17, weight: FontWeight.w700),
  );

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface;
    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(title: 'Миний өнгө', background: bg),
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            Row(
              children: [
                for (final (i, (mode, label)) in _modes.indexed) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ThemeModeTile(
                      mode: mode,
                      label: label,
                      selected: appBrightness.value == mode,
                      onTap: () => _setMode(mode),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),
            _heading('Дуртай өнгөө сонгоорой'),
            for (final (i, (choice, label)) in _accents.indexed) ...[
              // Room for the chosen card's tag above its edge.
              if (i > 0) const SizedBox(height: 18),
              AccentCard(
                choice: choice,
                label: label,
                selected: appThemeChoice.value == choice,
                onTap: () => _setAccent(choice),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

/// A slice of Home drawn with the live tokens, so the choice is visible
/// before leaving the screen.
class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.sky50,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: LineIcon(
                  LineGlyph.pocket,
                  size: 20,
                  color: AppColors.sky600,
                ),
              ),
              const SizedBox(width: 12),
              AppText(
                'Харилцах данс',
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.slate600,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            formatMnt(567930),
            style: moneyStyle(size: 30, weight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Шилжүүлэх', height: 48, onPressed: () {}),
        ],
      ),
    );
  }
}
