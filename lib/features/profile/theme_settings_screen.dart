import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

/// "Өнгөний тохиргоо": choose the app color theme.
class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  static const _themes = [
    (
      'Тэнгэрийн цэнхэр (Playful Blue)',
      'Эрч хүчтэй, цэлмэг цэнхэр өнгө төрх',
      'Хүү болон ерөнхий сэдэв',
      [AppColors.sky500, AppColors.sky400, AppColors.sky100, AppColors.sky600],
      Icons.water_drop_outlined,
    ),
    (
      'Сарнайн ягаан (Pastel Bloom)',
      'Зөөлөн дулаахан, ягаан өнгө төрх',
      'Охидын сэдэв',
      [
        AppColors.rose500,
        AppColors.rose400,
        AppColors.rose100,
        AppColors.rose600,
      ],
      Icons.local_florist_outlined,
    ),
  ];

  int _saved = 0;
  int _selected = 0;

  void _save() {
    // TODO: persist and apply the theme app-wide.
    setState(() => _saved = _selected);
    showAppSnack(context, '"${_themes[_selected].$3}" өнгө хадгалагдлаа ✨');
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F8FD);
    return Scaffold(
      backgroundColor: bg,
      appBar: const SubPageHeader(title: 'Өнгөний тохиргоо', background: bg),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
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
                  child: const MascotImage(
                    asset: Mascots.foxPhone,
                    size: 88,
                    background: Colors.white,
                    semanticLabel: 'PocketPal Fox Mascot',
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
                      Text(
                        'Аппын өнгийг өөрт таалагдсан өнгөөрөө ашиглаарай! ✨',
                        style: comfortaa(
                          size: 13,
                          weight: FontWeight.w500,
                          color: AppColors.slate600,
                          height: 1.5,
                        ),
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
            child: Text(
              'ҮНДСЭН СЭДВҮҮД',
              style: comfortaa(
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.slate400,
                letterSpacing: 0.6,
              ),
            ),
          ),
          for (final (i, t) in _themes.indexed) ...[
            _ThemeCard(
              title: t.$1,
              description: t.$2,
              tag: t.$3,
              swatches: t.$4,
              icon: t.$5,
              selected: _selected == i,
              active: _saved == i,
              onTap: () => setState(() => _selected = i),
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 4),
          PrimaryButton(
            label: 'Сонгосон өнгийг хадгалах',
            leadingIcon: Icons.check_rounded,
            color: _selected == 1 ? AppColors.rose500 : null,
            onPressed: _selected == _saved ? null : _save,
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.title,
    required this.description,
    required this.tag,
    required this.swatches,
    required this.icon,
    required this.selected,
    required this.active,
    required this.onTap,
  });

  final String title;
  final String description;
  final String tag;
  final List<Color> swatches;
  final IconData icon;
  final bool selected;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = swatches.first;
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        scale: 0.98,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected ? accent : AppColors.slate100,
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.18),
                          offset: const Offset(0, 8),
                          blurRadius: 20,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [swatches[1], swatches[3]],
                      ),
                    ),
                    child: Icon(icon, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: comfortaa(
                                  size: 13,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              width: 20,
                              height: 20,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? accent : AppColors.slate300,
                                  width: 2,
                                ),
                              ),
                              child: selected
                                  ? DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: accent,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: comfortaa(size: 12, color: AppColors.slate400),
                        ),
                        const Divider(height: 22, color: AppColors.slate100),
                        Row(
                          children: [
                            for (final c in swatches)
                              Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x14000000),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            const Spacer(),
                            Flexible(
                              flex: 4,
                              child: Text(
                                tag,
                                textAlign: TextAlign.right,
                                style: comfortaa(
                                  size: 11,
                                  weight: FontWeight.w600,
                                  color: accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (active)
              Positioned(
                top: -10,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Идэвхтэй',
                    style: comfortaa(
                      size: 10,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
