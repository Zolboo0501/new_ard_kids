import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/ui.dart';
import '../../../../widgets/value_switcher.dart';

class AvatarCard extends StatefulWidget {
  const AvatarCard({
    super.key,
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
  State<AvatarCard> createState() => _AvatarCardState();
}

class _AvatarCardState extends State<AvatarCard>
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
  void didUpdateWidget(AvatarCard old) {
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
