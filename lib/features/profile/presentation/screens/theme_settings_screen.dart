import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../theme/theme_store.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/accent_card.dart';
import '../widgets/theme_mode_tile.dart';

/// "Харагдац": light / dark / system canvas and the accent colour. Every
/// choice applies at once and is saved, like the phone's own settings.
class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  static const _modes = [
    (AppBrightness.system, 'Систем'),
    (AppBrightness.light, 'Гэрэл'),
    (AppBrightness.dark, 'Харанхуй'),
  ];

  /// Choice, name, English name, a line about it, and the tile's glyph.
  static const _accents = [
    (
      AppThemeChoice.sky,
      'Тэнгэр',
      'Sky',
      'Цэлмэг, эрч хүчтэй цэнхэр. Үндсэн сэдэв.',
      LineGlyph.sun,
    ),
    (
      AppThemeChoice.blue,
      'Цэнхэр',
      'Ocean',
      'Тайван, гүн далайн цэнхэр.',
      LineGlyph.pocket,
    ),
    (
      AppThemeChoice.indigo,
      'Индиго',
      'Indigo',
      'Орчин үеийн, тод индиго.',
      LineGlyph.bolt,
    ),
    (
      AppThemeChoice.pink,
      'Ягаан',
      'Bloom',
      'Дулаахан, зөөлөн ягаан.',
      LineGlyph.heart,
    ),
    (
      AppThemeChoice.lime,
      'Шар ногоон',
      'Lime',
      'Тод, шинэ маягийн шар ногоон.',
      LineGlyph.ball,
    ),
    (
      AppThemeChoice.mono,
      'Монохром',
      'Mono',
      'Хар цагаан, цэвэрхэн харагдац.',
      LineGlyph.moon,
    ),
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

  Widget _heading(String title, String note) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(title, size: 16, weight: FontWeight.w700),
        const SizedBox(height: 4),
        AppText(note, size: 13, color: AppColors.slate500, height: 1.4),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface;
    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(title: 'Харагдац', background: bg),
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            _heading('Горим', 'Системийг сонговол утасныхаа тохиргоог дагана.'),
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
            _heading(
              'Өнгө',
              'Товч, сонголт, тэмдэглэгээ болон дэвсгэрийн өнгө.',
            ),
            for (final (i, (choice, label, subtitle, note, glyph))
                in _accents.indexed) ...[
              if (i > 0) const SizedBox(height: 10),
              AccentCard(
                choice: choice,
                label: label,
                subtitle: subtitle,
                description: note,
                glyph: glyph,
                selected: appThemeChoice.value == choice,
                onTap: () => _setAccent(choice),
              ),
            ],
            const SizedBox(height: 32),
            _heading('Урьдчилан харах', 'Сонголт тань шууд хэрэгжинэ.'),
            const _Preview(),
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
