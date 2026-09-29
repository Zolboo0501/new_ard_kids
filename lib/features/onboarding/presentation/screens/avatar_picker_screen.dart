import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/avatar.dart';
import '../../../../app/biometrics.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../../auth/presentation/widgets/header.dart';
import '../widgets/avatar_card.dart';

/// "Аватараа сонго" (onboarding step 4/6): pick a profile avatar.
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

  /// Starts on the current avatar, so editing shows what's in use.
  late int _selected = appAvatar.value.index;

  /// Drives the one-shot entrance: each element fades and rises over its own
  /// slice of this controller (see [Entrance]).
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );
  late final EntranceStagger _stagger = EntranceStagger(_entrance);
  late final Animation<double> _headerIn;
  late final Animation<double> _titleIn;
  late final Animation<double> _subtitleIn;
  late final Animation<double> _buttonIn;

  /// One slice per card, so the grid deals itself out rather than appearing
  /// as a block.
  late final List<Animation<double>> _cardsIn;

  @override
  void initState() {
    super.initState();
    _headerIn = _stagger.slice(0);
    _titleIn = _stagger.slice(0.1);
    _subtitleIn = _stagger.slice(0.14);
    _cardsIn = [
      for (var i = 0; i < _avatars.length; i++) _stagger.slice(0.18 + i * 0.04),
    ];
    _buttonIn = _stagger.slice(0.34);
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
    showAppSnack(context, 'Аватар солигдлоо', mascot: avatar.portrait);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // All four in one row once there is room (iPad, tablets),
                  // two by two on phones.
                  final columns = constraints.maxWidth >= 640 ? 4 : 2;
                  return SingleChildScrollView(
                    padding: AppLayout.centered(
                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      constraints.maxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Entrance(
                          t: _headerIn,
                          child: Header(
                            step: widget.editing ? null : 'Алхам 4/6',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Entrance(
                          t: _titleIn,
                          child: AppText(
                            'Аватараа сонго',
                            size: 28,
                            weight: FontWeight.w700,
                            color: AppColors.slate900,
                            height: 1.2,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Entrance(
                          t: _subtitleIn,
                          child: AppText(
                            'Дараа нь Профайл хэсгээс солих боломжтой.',
                            size: 15,
                            color: AppColors.slate500,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 28),
                        GridView.count(
                          crossAxisCount: columns,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.82,
                          children: [
                            for (final (i, a) in _avatars.indexed)
                              Entrance(
                                t: _cardsIn[i],
                                offsetY: 16,
                                child: AvatarCard(
                                  name: a.name,
                                  asset: a.portrait,
                                  selected: _selected == i,
                                  onTap: () => setState(() => _selected = i),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Entrance(
              t: _buttonIn,
              offsetY: 24,
              child: AdaptiveCenter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: PrimaryButton(
                    label: widget.editing
                        ? 'Аватараа хадгалах'
                        : 'Үргэлжлүүлэх',
                    height: 56,
                    onPressed: _confirm,
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
