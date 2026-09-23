import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Round white back button used in the auth flow headers.
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Буцах',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          (onPressed ?? () => Navigator.of(context).maybePop())();
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.slate100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.chevron_left_rounded,
            size: 26,
            color: AppColors.slate700,
          ),
        ),
      ),
    );
  }
}

/// Thin blinking text cursor shown inside the active code box.
class BlinkingCursor extends StatefulWidget {
  const BlinkingCursor({super.key, this.color, this.height = 24});

  /// Defaults to the theme accent (`AppColors.sky500`).
  final Color? color;
  final double height;

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      child: Container(
        width: 2,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color ?? AppColors.sky500,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Mascot image with a white JPEG/PNG background blended into [background]
/// (equivalent of CSS `mix-blend-mode: multiply`).
class MascotImage extends StatelessWidget {
  const MascotImage({
    super.key,
    required this.asset,
    required this.size,
    required this.background,
    required this.semanticLabel,
  });

  final String asset;
  final double size;
  final Color background;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    // The JPEG mascots carry a white box that the multiply blend melts into
    // the surface; the PNG cutouts are already transparent, so blending them
    // would only tint the artwork.
    final cutout = asset.endsWith('.png');
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: cutout ? null : background,
      colorBlendMode: cutout ? null : BlendMode.multiply,
      semanticLabel: semanticLabel,
    );
  }
}

class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key});

  @override
  State<PulsingDot> createState() => PulsingDotState();
}

class PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.5).animate(_controller),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.sky500,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
