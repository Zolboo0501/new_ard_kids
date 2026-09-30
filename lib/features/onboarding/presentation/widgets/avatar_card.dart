import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/ui.dart';
import '../../../../widgets/value_switcher.dart';

/// One choice in the avatar grid: the portrait in a circle tinted with the
/// character's own [accent], the name under it, and a ring with a tick in
/// that accent while it is the selected one.
class AvatarCard extends StatefulWidget {
  const AvatarCard({
    super.key,
    required this.name,
    required this.asset,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String asset;

  /// The character's accent (see `AppAvatar.accent`).
  final AppThemeChoice accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<AvatarCard> createState() => _AvatarCardState();
}

class _AvatarCardState extends State<AvatarCard>
    with SingleTickerProviderStateMixin {
  /// Plays once each time this avatar becomes the chosen one.
  late final AnimationController _pick = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  /// A small settle on the portrait so the change registers without
  /// turning into a performance.
  late final Animation<double> _pop = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.06), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 60),
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
    final selected = widget.selected;
    final p = AppPalette.of(widget.accent);
    return Semantics(
      button: true,
      selected: selected,
      label: widget.name,
      excludeSemantics: true,
      child: Pressable(
        onTap: widget.onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final side = (constraints.maxWidth - 8).clamp(64.0, 132.0);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: side,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: appEmphasizedDecelerate,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? p.c500 : p.c200,
                              width: selected ? 2.5 : 1,
                            ),
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: p.c50,
                            ),
                            child: ClipOval(
                              child: ScaleTransition(
                                scale: _pop,
                                child: Center(
                                  child: MascotImage(
                                    asset: widget.asset,
                                    size: side * 0.78,
                                    background: p.c50,
                                    semanticLabel: widget.name,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: side * 0.04,
                        bottom: side * 0.04,
                        child: ValueSwitcher(
                          value: selected,
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation, _) =>
                              ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              ),
                          child: selected
                              ? Container(
                                  key: const ValueKey('tick'),
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: p.c500,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.surface,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: LineIcon(
                                      LineGlyph.check,
                                      size: 16,
                                      stroke: 2,
                                      color: p.onAccent,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(key: ValueKey('none')),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                AppText(
                  widget.name,
                  size: 14,
                  weight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppColors.slate900 : AppColors.slate600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
