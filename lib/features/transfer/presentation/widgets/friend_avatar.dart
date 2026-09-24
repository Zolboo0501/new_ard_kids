import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/ui.dart';

class FriendAvatar extends StatelessWidget {
  const FriendAvatar({
    super.key,
    required this.label,
    required this.onTap,
    this.asset,
    this.tint,
    this.selected = false,
  });

  final String label;
  final String? asset;
  final Color? tint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = this.tint ?? AppColors.sky50;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: withHaptic(onTap),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 54,
                    height: 54,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: BorderRadius.circular(16),
                      border: asset == null
                          ? null
                          : Border.all(
                              color: selected
                                  ? AppColors.sky500
                                  : tint.withValues(alpha: 0.9),
                              width: selected ? 2 : 1,
                            ),
                    ),
                    child: asset == null
                        ? CustomPaint(
                            painter: _DashedBoxPainter(),
                            child: Center(
                              child: Icon(
                                Icons.add_rounded,
                                color: AppColors.sky600,
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: MascotImage(
                              asset: asset!,
                              size: 50,
                              background: Colors.white,
                              semanticLabel: label,
                            ),
                          ),
                  ),
                  if (selected)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.sky600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              AppText(
                label,
                size: 11,
                weight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? AppColors.sky800 : AppColors.slate600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.sky300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      );
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 8) {
        canvas.drawPath(m.extractPath(d, d + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
