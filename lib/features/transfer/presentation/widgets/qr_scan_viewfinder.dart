import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// Everything drawn over the camera: the blur around the frame, the frame
/// corners, a sweeping scan line and the hint. Fills the whole camera view.
class QrScanViewfinder extends StatelessWidget {
  const QrScanViewfinder({super.key, required this.scan});

  final Animation<double> scan;

  /// Side of the square viewfinder; also the scan window.
  static const frame = 224.0;
  static const _inset = 24.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // Expand so the blur and the hint span the camera view, not just the
      // frame (a Stack otherwise sizes to its one non-positioned child).
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        // Blur and dim everything outside the frame so it's clear only the
        // square is read (the scan window matches it).
        const _OutsideBlur(),
        Center(
          child: SizedBox(
            width: frame,
            height: frame,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _CornerPainter()),
                ),
                AnimatedBuilder(
                  animation: scan,
                  builder: (_, _) => Positioned(
                    left: _inset,
                    right: _inset,
                    top:
                        _inset +
                        (frame - 2 * _inset) *
                            Curves.easeInOut.transform(scan.value),
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.sky400,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.sky400.withValues(alpha: 0.8),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Frosts the camera preview around the centred frame, leaving the square
/// sharp. It sizes itself, so it needs no [LayoutBuilder].
class _OutsideBlur extends StatelessWidget {
  const _OutsideBlur();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _HoleClipper(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: ColoredBox(color: Colors.black.withValues(alpha: 0.35)),
      ),
    );
  }
}

/// The whole area minus a centred [QrScanViewfinder.frame] square with
/// the same rounded corners as [_CornerPainter].
class _HoleClipper extends CustomClipper<Path> {
  const _HoleClipper();

  static const _radius = Radius.circular(18);

  @override
  Path getClip(Size size) => Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(Offset.zero & size)
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: size.center(Offset.zero),
          width: QrScanViewfinder.frame,
          height: QrScanViewfinder.frame,
        ),
        _radius,
      ),
    );

  @override
  bool shouldReclip(_HoleClipper old) => false;
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.sky400
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const l = 36.0;
    const r = 18.0;
    final w = size.width;
    final h = size.height;
    for (final (dx, dy) in [(0.0, 0.0), (w, 0.0), (0.0, h), (w, h)]) {
      final sx = dx == 0 ? 1 : -1;
      final sy = dy == 0 ? 1 : -1;
      final path = Path()
        ..moveTo(dx, dy + sy * l)
        ..lineTo(dx, dy + sy * r)
        ..arcToPoint(
          Offset(dx + sx * r, dy),
          radius: const Radius.circular(r),
          clockwise: sx == sy,
        )
        ..lineTo(dx + sx * l, dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
