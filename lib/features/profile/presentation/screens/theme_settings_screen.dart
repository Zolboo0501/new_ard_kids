import 'package:flutter/material.dart';

import '../../../../app/avatar.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/theme_store.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/theme_card.dart';

/// "Өнгөний тохиргоо": choose the app color theme.
class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  static const _themes = [
    (
      AppThemeChoice.blue,
      'Тэнгэрийн цэнхэр (Playful Blue)',
      'Эрч хүчтэй, цэлмэг цэнхэр өнгө төрх',
      'Хүү болон ерөнхий сэдэв',
      AppPalette.blue,
      Icons.water_drop_outlined,
    ),
    (
      AppThemeChoice.pink,
      'Сарнайн ягаан (Pastel Bloom)',
      'Зөөлөн дулаахан, ягаан өнгө төрх',
      'Охидын сэдэв',
      AppPalette.pink,
      Icons.local_florist_outlined,
    ),
  ];

  late AppThemeChoice _selected = appThemeChoice.value;

  void _save() {
    appThemeChoice.value = _selected;
    ThemeStore.save(_selected);
    final tag = _themes.firstWhere((t) => t.$1 == _selected).$4;
    showAppSnack(context, '"$tag" өнгө хадгалагдлаа');
  }

  @override
  Widget build(BuildContext context) {
    const bg = AppColors.surface;
    return Scaffold(
      backgroundColor: bg,
      appBar: const SubPageHeader(title: 'Өнгөний тохиргоо', background: bg),
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            Container(
              padding: const EdgeInsets.all(16),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(22),
                // A faint wash of the theme accent from the top-left corner.
                gradient: RadialGradient(
                  center: const Alignment(-1, -1),
                  radius: 1.4,
                  colors: [
                    Color.alphaBlend(
                      AppColors.sky500.withValues(alpha: 0.14),
                      AppColors.card,
                    ),
                    AppColors.card,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Night.surface2,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: MascotImage(
                      asset: Stickers.edit,
                      size: 88,
                      background: Night.surface2,
                      semanticLabel: 'Үнэг маскот',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const StatusBadge(
                          label: 'Өөрийн хэв маяг',
                          icon: Icons.auto_awesome_rounded,
                        ),
                        const SizedBox(height: 6),
                        AppText(
                          'Аппын өнгийг өөрт таалагдсан өнгөөрөө ашиглаарай!',
                          size: 13,
                          weight: FontWeight.w500,
                          color: AppColors.slate600,
                          height: 1.5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: AppText(
                'ҮНДСЭН СЭДВҮҮД',
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.slate400,
                letterSpacing: 0.6,
              ),
            ),
            for (final t in _themes) ...[
              ThemeCard(
                title: t.$2,
                description: t.$3,
                tag: t.$4,
                palette: t.$5,
                icon: t.$6,
                selected: _selected == t.$1,
                active: appThemeChoice.value == t.$1,
                onTap: () => setState(() => _selected = t.$1),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 4),
            PrimaryButton(
              label: 'Сонгосон өнгийг хадгалах',
              leadingIcon: Icons.check_rounded,
              color: AppPalette.of(_selected).c500,
              foreground: AppPalette.of(_selected).onAccent,
              onPressed: _selected == appThemeChoice.value ? null : _save,
            ),
          ]),
        ),
      ),
    );
  }
}
