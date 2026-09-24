import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// Decorative QR-like pattern (not a scannable code).
class FakeQrPainter extends CustomPainter {
  const FakeQrPainter({required this.seed});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    const n = 25;
    final cell = size.width / n;
    final paint = Paint()..color = AppColors.slate800;
    final rnd = math.Random(seed);

    bool inFinder(int x, int y) {
      bool box(int ox, int oy) =>
          x >= ox && x < ox + 7 && y >= oy && y < oy + 7;
      return box(0, 0) || box(n - 7, 0) || box(0, n - 7);
    }

    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final center = (x - n / 2).abs() < 4 && (y - n / 2).abs() < 4;
        if (inFinder(x, y) || center) continue;
        if (rnd.nextDouble() < 0.48) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x * cell, y * cell, cell, cell).deflate(0.4),
              Radius.circular(cell * 0.25),
            ),
            paint,
          );
        }
      }
    }

    void finder(double ox, double oy) {
      final outer = Rect.fromLTWH(ox, oy, cell * 7, cell * 7);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          outer.deflate(cell / 2),
          Radius.circular(cell * 1.4),
        ),
        Paint()
          ..color = AppColors.slate800
          ..style = PaintingStyle.stroke
          ..strokeWidth = cell,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          outer.deflate(cell * 2),
          Radius.circular(cell * 0.8),
        ),
        paint,
      );
    }

    finder(0, 0);
    finder(size.width - cell * 7, 0);
    finder(0, size.height - cell * 7);
  }

  @override
  bool shouldRepaint(FakeQrPainter old) => old.seed != seed;
}
