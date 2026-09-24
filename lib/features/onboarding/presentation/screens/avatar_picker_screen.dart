import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/avatar.dart';
import '../../../../app/biometrics.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../../auth/presentation/widgets/header.dart';
import '../widgets/avatar_card.dart';
import '../widgets/avatar_picker_blob.dart';

/// "Аватар сонгох" (onboarding step 4/6): pick a mascot companion.
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
  static const _avatars = AppAvatar.values;

  /// Starts on the current companion, so editing shows what's in use.
  late int _selected = appAvatar.value.index;

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

  /// Offers biometric sign-in next, unless the phone has no sensor for it.
  Future<void> _next() async {
    final hasSensor = await Biometrics.instance.hasSensor();
    if (!mounted) return;
    context.push(
      hasSensor ? AppRoutes.biometricSetup : AppRoutes.parentLinkOnboarding,
    );
  }

  void _confirm() {
    final avatar = _avatars[_selected];
    appAvatar.value = avatar;
    AvatarStore.save(avatar);
    if (!widget.editing) {
      _next();
      return;
    }
    showAppSnack(
      context,
      '${avatar.name} таны шинэ найз боллоо',
      mascot: avatar.pick,
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
            child: AvatarPickerBlob(size: 288, color: Color(0x80BAE6FD)),
          ),
          const Positioned(
            top: 192,
            right: -80,
            child: AvatarPickerBlob(size: 256, color: Color(0x99FEF3C7)),
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
                          child: Header(
                            step: widget.editing ? null : 'Алхам 4/6',
                          ),
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
                              MascotIcon(_avatars[_selected].pick, size: 30),
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
                                child: AvatarCard(
                                  name: a.name,
                                  role: a.role,
                                  description: a.description,
                                  asset: a.pick,
                                  tone: a.tone,
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
