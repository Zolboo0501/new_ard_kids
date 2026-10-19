import 'package:flutter/material.dart';

import '../app/avatar.dart';
import '../app/tour_store.dart';
import '../theme/app_theme.dart';
import 'app_text.dart';
import 'ui.dart';

/// One stop of [AvatarTour]: the part of the screen to spotlight (none for
/// the greeting) and what the avatar says about it.
class AvatarTourStep {
  const AvatarTourStep({this.target, required this.text});

  final GlobalKey? target;
  final String text;
}

/// Opens [AvatarTour] over the whole app, the bottom bar included.
Future<void> showAvatarTour(
  BuildContext context, {
  required List<AvatarTourStep> steps,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    barrierLabel: 'Танилцуулга',
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, _, _) => AvatarTour(steps: steps),
    transitionBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// A screen's first-visit tour, led by the teen's avatar: the screen dims,
/// the part being explained sits in a soft spotlight (scrolled into view
/// first), and the avatar explains it in a speech bubble beside it. Дараах
/// moves on, Алгасах ends it; both close the dialog when done. Screens start
/// it with [AvatarTourHost].
///
/// The first step should be a greeting with no target: it opens while the
/// screen may still be sliding in, and the first spotlight is measured only
/// after the teen moves on.
class AvatarTour extends StatefulWidget {
  const AvatarTour({super.key, required this.steps});

  final List<AvatarTourStep> steps;

  @override
  State<AvatarTour> createState() => _AvatarTourState();
}

class _AvatarTourState extends State<AvatarTour> {
  int _index = 0;

  /// The spotlight, in this overlay's coordinates; null for no spotlight.
  Rect? _hole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus());
  }

  AvatarTourStep get _step => widget.steps[_index];
  bool get _last => _index == widget.steps.length - 1;

  /// Scrolls the step's target into view, then spotlights it.
  Future<void> _focus() async {
    final target = _step.target?.currentContext;
    if (target == null) {
      setState(() => _hole = null);
      return;
    }
    final still = MediaQuery.disableAnimationsOf(context);
    await Scrollable.ensureVisible(
      target,
      alignment: 0.3,
      duration: still ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    if (!mounted || !target.mounted) return;
    final box = target.findRenderObject() as RenderBox?;
    final self = context.findRenderObject() as RenderBox?;
    if (box == null || self == null || !box.attached) return;
    // Through global coordinates, so the whole-app scale cancels out.
    final topLeft = self.globalToLocal(box.localToGlobal(Offset.zero));
    final bottomRight = self.globalToLocal(
      box.localToGlobal(box.size.bottomRight(Offset.zero)),
    );
    setState(() => _hole = Rect.fromPoints(topLeft, bottomRight).inflate(8));
  }

  void _next() {
    if (_last) return _close();
    setState(() => _index++);
    _focus();
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final avatar = appAvatar.value;
    final still = MediaQuery.disableAnimationsOf(context);
    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hole = _hole;
          final size = constraints.biggest;
          final padding = MediaQuery.paddingOf(context);
          // The bubble goes under the spotlight, or over it, wherever it
          // fits; a target taller than the screen (a whole list) leaves room
          // on neither side, so the bubble then sits at the bottom of the
          // screen, over the spotlight, and its buttons stay reachable.
          final screen = Rect.fromLTRB(
            0,
            padding.top,
            size.width,
            size.height - padding.bottom,
          );
          final shown = hole?.intersect(screen);
          final double? top;
          final double? bottom;
          if (shown == null) {
            top = bottom = null;
          } else if (screen.bottom - shown.bottom >= _bubbleRoom) {
            top = shown.bottom + 12;
            bottom = null;
          } else if (shown.top - screen.top >= _bubbleRoom) {
            top = null;
            bottom = size.height - shown.top + 12;
          } else {
            top = null;
            bottom = padding.bottom + 16;
          }
          return Stack(
            children: [
              // The dim with the spotlight cut out; it takes the taps, so
              // the screen underneath can't be used mid-tour.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  // No spotlight is an empty one at the centre, so the
                  // first real one grows out from the middle.
                  child: TweenAnimationBuilder<Rect?>(
                    tween: RectTween(
                      end:
                          hole ??
                          Rect.fromCenter(
                            center: size.center(Offset.zero),
                            width: 0,
                            height: 0,
                          ),
                    ),
                    duration: still
                        ? Duration.zero
                        : const Duration(milliseconds: 320),
                    curve: appEmphasizedDecelerate,
                    builder: (context, rect, _) => CustomPaint(
                      painter: _SpotlightPainter(
                        hole: rect,
                        color: Colors.black.withValues(alpha: 0.62),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: still
                    ? Duration.zero
                    : const Duration(milliseconds: 320),
                curve: appEmphasizedDecelerate,
                left: 16,
                right: 16,
                top: top,
                bottom: bottom,
                child: hole == null
                    ? SizedBox(
                        height: size.height - padding.vertical,
                        child: Center(child: _bubble(avatar)),
                      )
                    : _bubble(avatar),
              ),
            ],
          );
        },
      ),
    );
  }

  /// How tall the guide stands, and how far it rises out of the bubble.
  static const _guideHeight = 132.0;
  static const _guideRise = 28.0;

  /// The height the bubble needs beside a spotlight (the guide's head
  /// included, with a margin), at the default text size.
  static const _bubbleRoom = 230.0;

  Widget _bubble(AppAvatar avatar) {
    return _BubbleIn(
      key: ValueKey(_index),
      // Room above the bubble for the guide's head.
      child: Padding(
        padding: const EdgeInsets.only(top: _guideRise),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(kCardRadius),
                boxShadow: cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // The words beside the guide, at least as tall as its
                  // body inside the bubble, so the buttons sit under its
                  // feet.
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: _guideHeight - _guideRise - 14,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 96),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            avatar.name,
                            size: 15,
                            weight: FontWeight.w700,
                            color: AppColors.slate900,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            _step.text,
                            size: 14,
                            height: 1.45,
                            color: AppColors.slate700,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Where the tour is.
                      for (var i = 0; i < widget.steps.length; i++)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: i == _index ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? AppColors.sky500
                                : AppColors.slate200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      const Spacer(),
                      if (!_last)
                        TextButton(
                          onPressed: _close,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(44, 44),
                          ),
                          child: AppText(
                            'Алгасах',
                            size: 14,
                            weight: FontWeight.w600,
                            color: AppColors.slate500,
                          ),
                        ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 128,
                        child: PrimaryButton(
                          label: _last ? 'Эхэлцгээе' : 'Дараах',
                          height: 44,
                          onPressed: _next,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // The guide: the whole character, standing at the bubble's
            // left edge with its head above it.
            Positioned(
              left: 4,
              top: -_guideRise,
              width: 104,
              height: _guideHeight,
              child: Image.asset(
                avatar.fullBody,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                filterQuality: FilterQuality.high,
                excludeFromSemantics: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A soft fade-and-rise for each new bubble.
class _BubbleIn extends StatelessWidget {
  const _BubbleIn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Transform.translate(
        offset: Offset(0, 12 * (1 - t)),
        child: Opacity(opacity: t, child: child),
      ),
      child: child,
    );
  }
}

/// The dim over everything, with a rounded hole around [hole].
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({required this.hole, required this.color});

  final Rect? hole;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    if (hole case final h? when !h.isEmpty) {
      path.addRRect(RRect.fromRectAndRadius(h, const Radius.circular(28)));
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.hole != hole || old.color != color;
}

/// Gives a screen its first-visit avatar tour: call [startAvatarTour] from
/// `initState`. The tour opens after the first frame, once, if the screen
/// is on top and its tour is still owed ([TourStore]); it is marked done as
/// it opens, so leaving midway never brings it back.
mixin AvatarTourHost<T extends StatefulWidget> on State<T> {
  void startAvatarTour(String id, List<AvatarTourStep> Function() steps) {
    if (!TourStore.pending(id)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !TourStore.pending(id)) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      // Done up front, so it can't open twice.
      TourStore.complete(id);
      await showAvatarTour(context, steps: steps());
    });
  }
}
