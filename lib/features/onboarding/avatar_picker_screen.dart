import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_ard_kids/features/auth/presentation/widgets/header.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';

/// "Аватар сонгох" (onboarding step 3/3): pick a mascot companion.
///
/// With [editing] (opened from Profile) there is no step indicator or skip,
/// and confirming returns to the previous screen.
class AvatarPickerScreen extends StatefulWidget {
  const AvatarPickerScreen({super.key, this.editing = false});

  final bool editing;

  @override
  State<AvatarPickerScreen> createState() => _AvatarPickerScreenState();
}

class _AvatarPickerScreenState extends State<AvatarPickerScreen> {
  static const _avatars = [
    (
      'Үнэгхэн',
      'Гүйлгээний мастер',
      'Мөнгөө хурдан, ухаалгаар тооцоолно!',
      Mascots.foxPhone,
      BadgeTone.sky,
    ),
    (
      'Бамбарууш',
      'Хадгаламж сахигч',
      'Мөнгөө зорилгодоо хүртэл найдвартай хадгална!',
      Mascots.bearCard,
      BadgeTone.emerald,
    ),
    (
      'Бөжинхөн',
      'Данс цэнэглэгч',
      'Эрч хүчтэйгээр өдөр бүр даалгавар биелүүлнэ!',
      Mascots.bunnyBattery,
      BadgeTone.amber,
    ),
    (
      'Шувуухай',
      'Хяналтын нярав',
      'Зарцуулалт ба тайлангаа нямбай тэмдэглэнэ!',
      Mascots.penguinChecklist,
      BadgeTone.slate,
    ),
  ];

  int _selected = 0;

  void _next() => context.push(AppRoutes.parentLink);

  void _confirm() {
    if (!widget.editing) return _next();
    // TODO: persist the chosen avatar.
    showAppSnack(context, '${_avatars[_selected].$1} таны шинэ найз боллоо 🐾');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dsSurface,
      body: Stack(
        children: [
          const Positioned(
            top: -96,
            left: -80,
            child: _Blob(size: 288, color: Color(0x80BAE6FD)),
          ),
          const Positioned(
            top: 192,
            right: -80,
            child: _Blob(size: 256, color: Color(0x99FEF3C7)),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      children: [
                        const Header(step: 'Алхам 3/4'),
                        const SizedBox(height: 18),
                        const StatusBadge(
                          label: '✨ Өөрийн бяцхан туслахыг сонгоорой',
                          tone: BadgeTone.amber,
                        ),
                        const SizedBox(height: 10),
                        AppText(
                          'Найзаа сонгоорой! 🐾',
                          size: 24,
                          weight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                        const SizedBox(height: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 280),
                          child: AppText(
                            'Энэхүү бяцхан амьтан таны хуримтлал, гүйлгээ бүрт хамт байж урам өгөх болно.',
                            size: 12,
                            color: AppColors.slate500,
                            height: 1.6,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.82,
                          children: [
                            for (final (i, a) in _avatars.indexed)
                              _AvatarCard(
                                name: a.$1,
                                role: a.$2,
                                description: a.$3,
                                asset: a.$4,
                                tone: a.$5,
                                selected: _selected == i,
                                onTap: () => setState(() => _selected = i),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.sky100.withValues(alpha: 0.7),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.sky100.withValues(
                                    alpha: 0.8,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.info_outline_rounded,
                                  size: 20,
                                  color: AppColors.sky600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text:
                                        'Санаа зоволтгүй ээ! Та сонгосон аватараа дараа нь ',
                                    children: [
                                      TextSpan(
                                        text: 'Профайл',
                                        style: comfortaa(
                                          size: 11,
                                          weight: FontWeight.w700,
                                          color: AppColors.sky600,
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            ' цэснээс хүссэн үедээ сольж болно.',
                                      ),
                                    ],
                                  ),
                                  style: comfortaa(
                                    size: 11,
                                    color: AppColors.slate600,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: PrimaryButton(
                    label: widget.editing
                        ? 'Аватараа хадгалах ✨'
                        : 'Сонгосон найзаа батлах 🚀',
                    height: 56,
                    onPressed: _confirm,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.sky50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.sky100.withValues(alpha: 0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.sky500,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          AppText(
            label,
            size: 12,
            weight: FontWeight.w700,
            color: AppColors.sky600,
          ),
        ],
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({
    required this.name,
    required this.role,
    required this.description,
    required this.asset,
    required this.tone,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String role;
  final String description;
  final String asset;
  final BadgeTone tone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, _) = tone.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: '$name - $role',
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? AppColors.sky400 : AppColors.slate100,
              width: 2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.sky400.withValues(alpha: 0.2),
                      offset: const Offset(0, 8),
                      blurRadius: 20,
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.sky500 : Colors.white,
                    border: selected
                        ? null
                        : Border.all(color: AppColors.slate300, width: 2),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MascotImage(
                    asset: asset,
                    size: 80,
                    background: Colors.white,
                    semanticLabel: name,
                  ),
                  const SizedBox(height: 6),
                  AppText(name, size: 12, weight: FontWeight.w700),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: AppText(
                      role,
                      size: 9,
                      weight: FontWeight.w700,
                      color: tone == BadgeTone.slate ? AppColors.violet500 : fg,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    description,
                    size: 10,
                    color: AppColors.slate400,
                    height: 1.3,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
