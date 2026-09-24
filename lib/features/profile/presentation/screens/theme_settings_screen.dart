import 'package:flutter/material.dart';

import '../../../../app/avatar.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/theme_store.dart';
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
    const bg = Color(0xFFF6F8FD);
    return Scaffold(
      backgroundColor: bg,
      appBar: const SubPageHeader(title: 'Өнгөний тохиргоо', background: bg),
      body: EntranceScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [AppColors.sky50, AppColors.pink50],
                ),
                border: Border.all(color: AppColors.sky100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: MascotImage(
                      asset: Stickers.edit,
                      size: 88,
                      background: Colors.white,
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
              onPressed: _selected == appThemeChoice.value ? null : _save,
            ),
          ]),
        ),
      ),
    );
  }
}
