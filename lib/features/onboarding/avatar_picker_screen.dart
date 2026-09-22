import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_ard_kids/features/auth/presentation/widgets/header.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text.dart';
import '../../widgets/common.dart';
import '../../widgets/entrance.dart';
import '../../widgets/ui.dart';
import '../../widgets/value_switcher.dart';

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

class _AvatarPickerScreenState extends State<AvatarPickerScreen>
    with SingleTickerProviderStateMixin {
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
      'Бүжинхэн',
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

  /// Drives the one-shot entrance: each element fades and rises over its own
  /// slice of this controller (see [Entrance]).
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );
  late final EntranceStagger _stagger = EntranceStagger(_entrance);
  late final Animation<double> _headerIn;
  late final Animation<double> _badgeIn;
  late final Animation<double> _titleIn;
  late final Animation<double> _subtitleIn;
  late final Animation<double> _noteIn;
  late final Animation<double> _buttonIn;

  /// One slice per card, so the grid deals itself out rather than appearing
  /// as a block.
  late final List<Animation<double>> _cardsIn;

  @override
  void initState() {
    super.initState();
    _headerIn = _stagger.slice(0);
    _badgeIn = _stagger.slice(0.06);
    _titleIn = _stagger.slice(0.1);
    _subtitleIn = _stagger.slice(0.14);
    _cardsIn = [
      for (var i = 0; i < _avatars.length; i++) _stagger.slice(0.18 + i * 0.04),
    ];
    _noteIn = _stagger.slice(0.34);
    _buttonIn = _stagger.slice(0.38);
    _entrance.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced motion: show the finished layout instead of animating it in.
    if (MediaQuery.disableAnimationsOf(context)) _entrance.value = 1;
  }

  @override
  void dispose() {
    _stagger.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _next() => context.push(AppRoutes.parentLink);

  void _confirm() {
    if (!widget.editing) return _next();
    // TODO: persist the chosen avatar.
    showAppSnack(
      context,
      '${_avatars[_selected].$1} таны шинэ найз боллоо',
      mascot: _avatars[_selected].$4,
    );
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
                        Entrance(
                          t: _headerIn,
                          child: const Header(step: 'Алхам 3/4'),
                        ),
                        const SizedBox(height: 18),
                        Entrance(
                          t: _badgeIn,
                          child: const StatusBadge(
                            label: 'Өөрийн бяцхан туслахыг сонгоорой',
                            tone: BadgeTone.amber,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Entrance(
                          t: _titleIn,
                          // The animal next to the title is whichever friend
                          // is currently picked.
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const AppText(
                                'Найзаа сонгоорой!',
                                size: 24,
                                weight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                              const SizedBox(width: 8),
                              MascotIcon(_avatars[_selected].$4, size: 30),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Entrance(
                          t: _subtitleIn,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: const AppText(
                              'Энэхүү бяцхан амьтан таны хуримтлал, гүйлгээ бүрт хамт байж урам өгөх болно.',
                              size: 12,
                              color: AppColors.slate500,
                              height: 1.6,
                              textAlign: TextAlign.center,
                            ),
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
                              Entrance(
                                t: _cardsIn[i],
                                offsetY: 20,
                                scaleFrom: 0.94,
                                child: _AvatarCard(
                                  name: a.$1,
                                  role: a.$2,
                                  description: a.$3,
                                  asset: a.$4,
                                  tone: a.$5,
                                  selected: _selected == i,
                                  onTap: () => setState(() => _selected = i),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Entrance(
                          t: _noteIn,
                          child: Container(
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
                                  child: Icon(
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
                                          style: inter(
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
                                    style: inter(
                                      size: 11,
                                      color: AppColors.slate600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Entrance(
                  t: _buttonIn,
                  offsetY: 24,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: PrimaryButton(
                      label: widget.editing
                          ? 'Аватараа хадгалах'
                          : 'Сонгосон найзаа батлах ',
                      height: 56,
                      onPressed: _confirm,
                    ),
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
            decoration: BoxDecoration(
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

class _AvatarCard extends StatefulWidget {
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
  State<_AvatarCard> createState() => _AvatarCardState();
}

class _AvatarCardState extends State<_AvatarCard>
    with SingleTickerProviderStateMixin {
  /// Plays once each time this card becomes the chosen one.
  late final AnimationController _pick = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  /// A quick squash-and-stretch on the mascot so picking feels like the
  /// character reacting, not just a border changing colour.
  late final Animation<double> _pop = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.14), weight: 35),
    TweenSequenceItem(tween: Tween(begin: 1.14, end: 0.97), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 0.97, end: 1.0), weight: 35),
  ]).animate(CurvedAnimation(parent: _pick, curve: Curves.easeOut));

  @override
  void didUpdateWidget(_AvatarCard old) {
    super.didUpdateWidget(old);
    if (!old.selected &&
        widget.selected &&
        !MediaQuery.disableAnimationsOf(context)) {
      _pick.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.name;
    final role = widget.role;
    final description = widget.description;
    final asset = widget.asset;
    final tone = widget.tone;
    final selected = widget.selected;
    final onTap = widget.onTap;
    final (bg, fg, _) = tone.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: '$name - $role',
      child: Pressable(
        onTap: onTap,
        // The chosen card sits a touch proud of the others.
        child: AnimatedScale(
          scale: selected ? 1.03 : 1,
          duration: const Duration(milliseconds: 240),
          curve: appEmphasizedDecelerate,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: appEmphasizedDecelerate,
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
                    duration: const Duration(milliseconds: 240),
                    curve: appEmphasizedDecelerate,
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.sky500 : Colors.white,
                      border: selected
                          ? null
                          : Border.all(color: AppColors.slate300, width: 2),
                    ),
                    child: ValueSwitcher(
                      value: selected,
                      duration: const Duration(milliseconds: 240),
                      switchInCurve: Curves.easeOutBack,
                      transitionBuilder: (child, animation, _) =>
                          ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          ),
                      child: selected
                          ? const Icon(
                              Icons.check_rounded,
                              key: ValueKey('tick'),
                              size: 14,
                              color: Colors.white,
                            )
                          : const SizedBox.shrink(key: ValueKey('none')),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _pop,
                      child: MascotImage(
                        asset: asset,
                        size: 80,
                        background: Colors.white,
                        semanticLabel: name,
                      ),
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
                        color: tone == BadgeTone.slate
                            ? AppColors.violet500
                            : fg,
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
      ),
    );
  }
}
