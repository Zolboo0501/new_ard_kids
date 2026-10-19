import 'dart:async';

import 'package:flutter/material.dart';

import '../app/avatar.dart';
import '../app/sounds.dart';
import '../theme/app_theme.dart';
import 'app_text.dart';

/// Shows the teen's avatar with a short [text] at the top of the screen, on
/// its own card shadow over the page (nothing behind it is dimmed or
/// blurred), and takes it away by itself after [duration], on a tap, or when
/// it is dragged up. Every message an action leaves (`showAppSnack`, the
/// rewards) goes through it; tours use `showAvatarTour` instead. A new one
/// replaces the one showing.
///
/// [top] is measured from under the status bar; by default it sits at the
/// very top, over the screen's header. [art] replaces the character's
/// [AppAvatar.fullBody].
void showAvatarToast(
  BuildContext context,
  String text, {
  double top = 4,
  String? art,
  Duration duration = const Duration(milliseconds: 4500),
}) {
  final overlay = Overlay.of(context);
  _current?.remove();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => AvatarToast(
      text: text,
      top: top,
      art: art,
      duration: duration,
      onDone: () {
        if (entry.mounted) entry.remove();
        if (identical(_current, entry)) _current = null;
      },
    ),
  );
  _current = entry;
  overlay.insert(entry);
}

/// The toast on screen, if any, so the next one can replace it.
OverlayEntry? _current;

/// What each rewarded action earns: a transfer, a savings deposit, a new
/// goal, an invite shared.
// TODO: take the reward from the API's response.
const rewardPoints = 100;

/// The avatar toast for a rewarded action: [lead] (what just happened, a
/// full sentence) and what it earned, with the purchase sound. The
/// character greets it in [pose] (see [AppAvatar.rewardArt]).
void showRewardToast(
  BuildContext context, {
  String? lead,
  RewardPose pose = RewardPose.success,
}) {
  AppSounds.instance.play(AppSounds.purchase);
  showAvatarToast(
    context,
    [?lead, 'Танд $rewardPoints ардын эрх орлоо!'].join(' '),
    art: appAvatar.value.rewardArt(pose),
  );
}

/// The toast [showAvatarToast] puts up: the whole character standing at the
/// left of a small card, dropping in from the top and rising away again.
class AvatarToast extends StatefulWidget {
  const AvatarToast({
    super.key,
    required this.text,
    required this.top,
    this.art,
    required this.duration,
    required this.onDone,
  });

  final String text;
  final double top;
  final String? art;
  final Duration duration;
  final VoidCallback onDone;

  @override
  State<AvatarToast> createState() => _AvatarToastState();
}

class _AvatarToastState extends State<AvatarToast>
    with SingleTickerProviderStateMixin {
  static const _guideWidth = 72.0;
  static const _guideHeight = 92.0;

  /// How far the character's head stands above the card.
  static const _guideRise = 26.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    reverseDuration: const Duration(milliseconds: 220),
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: appEmphasizedDecelerate,
    reverseCurve: appEmphasizedAccelerate,
  );
  Timer? _timer;
  bool _leaving = false;

  /// How far the card has been dragged: up follows the finger, down only
  /// gives a little.
  double _drag = 0;

  /// Past this (or a quick flick up) a drag dismisses it.
  static const _dismissDrag = 36.0;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(widget.duration, _leave);
  }

  Future<void> _leave() async {
    if (_leaving) return;
    _leaving = true;
    _timer?.cancel();
    await _controller.reverse();
    widget.onDone();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_leaving) return;
    _timer?.cancel();
    setState(() {
      final next = _drag + d.delta.dy;
      _drag = next < 0 ? next : next * 0.3;
    });
  }

  void _onDragEnd(DragEndDetails d) {
    if (_leaving) return;
    if (_drag < -_dismissDrag || d.velocity.pixelsPerSecond.dy < -400) {
      _leave();
      return;
    }
    // Let go short of it: back into place, and the clock starts again.
    setState(() => _drag = 0);
    _timer = Timer(widget.duration, _leave);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = appAvatar.value;
    final still = MediaQuery.disableAnimationsOf(context);
    return _buildToast(context, avatar, still);
  }

  Widget _buildToast(BuildContext context, AppAvatar avatar, bool still) {
    return Positioned(
      left: 16,
      right: 16,
      top: widget.top + MediaQuery.paddingOf(context).top,
      child: SafeArea(
        top: false,
        bottom: false,
        child: AnimatedBuilder(
          animation: _curve,
          builder: (context, child) => Opacity(
            opacity: _curve.value,
            child: Transform.translate(
              offset: Offset(0, (still ? 0 : -24 * (1 - _curve.value)) + _drag),
              child: child,
            ),
          ),
          // An overlay has no Material above it, which text needs for its
          // default style.
          child: Material(
            type: MaterialType.transparency,
            child: Semantics(
              liveRegion: true,
              child: GestureDetector(
                onTap: _leave,
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
                child: Padding(
                  padding: const EdgeInsets.only(top: _guideRise),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          minHeight: _guideHeight - _guideRise,
                        ),
                        padding: const EdgeInsets.fromLTRB(
                          _guideWidth + 12,
                          12,
                          16,
                          12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 24,
                              spreadRadius: -4,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              avatar.name,
                              size: 13,
                              weight: FontWeight.w700,
                              color: AppColors.sky600,
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              widget.text,
                              size: 15,
                              weight: FontWeight.w600,
                              color: AppColors.slate900,
                              height: 1.35,
                            ),
                          ],
                        ),
                      ),
                      // The character, standing on the card's bottom edge with
                      // its head above the top.
                      Positioned(
                        left: 6,
                        bottom: 0,
                        width: _guideWidth,
                        height: _guideHeight,
                        child: Image.asset(
                          widget.art ?? avatar.fullBody,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          filterQuality: FilterQuality.high,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
