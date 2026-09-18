import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_tabs.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';

/// "QR уншуулах": scanner viewfinder plus the "Миний QR" tab.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with SingleTickerProviderStateMixin {
  late final _scan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  int _tab = 0;
  bool _torch = false;

  @override
  void dispose() {
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dsSurface,
      appBar: SubPageHeader(
        title: 'QR уншуулах',
        background: AppColors.dsSurface,
        trailing: CircleIconButton(
          icon: _torch ? Icons.flashlight_on_rounded : Icons.highlight_rounded,
          label: 'Гэрэл асаах/унтраах',
          color: _torch ? AppColors.amber500 : AppColors.slate600,
          onPressed: () => setState(() => _torch = !_torch),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          AppTabs(
            tabs: const [
              AppTab('QR унших', icon: Icons.qr_code_scanner_rounded),
              AppTab('Миний QR', icon: Icons.qr_code_2_rounded),
            ],
            index: _tab,
            style: AppTabsStyle.solid,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 16),
          AppTabView(
            index: _tab,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _tab == 0 ? _buildScan() : _buildMyQr(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildScan() {
    return [
      AspectRatio(
        aspectRatio: 0.82,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF101B2B),
                        Color(0xFF1A2838),
                        Color(0xFF0F1A28),
                      ],
                    ),
                  ),
                ),
              ),
              if (_torch)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              SizedBox(
                width: 224,
                height: 224,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: CustomPaint(painter: _CornerPainter()),
                    ),
                    Center(
                      child: Container(
                        width: 176,
                        height: 176,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.filter_center_focus_rounded,
                          size: 36,
                          color: AppColors.sky300.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _scan,
                      builder: (_, _) => Positioned(
                        left: 24,
                        right: 24,
                        top: 24 + 176 * Curves.easeInOut.transform(_scan.value),
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
              Positioned(
                bottom: 20,
                child: AppText(
                  'QR кодыг хүрээн дотор байрлуулна уу',
                  size: 12,
                  weight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: SoftButton(
              label: 'Зургаас унших',
              icon: Icons.image_outlined,
              onPressed: () => showAppSnack(context, 'Зургийн сан нээгдэнэ'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SoftButton(
              label: 'Гараар оруулах',
              icon: Icons.keyboard_alt_outlined,
              onPressed: () => context.pushReplacement(AppRoutes.transfer),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      const InfoNote(
        icon: Icons.shield_outlined,
        text:
            'Энэ гүйлгээ нь аав ээжийн тохируулсан өдрийн ₮100,000 лимитийн хүрээнд хамгаалагдсан байна.',
      ),
    ];
  }

  List<Widget> _buildMyQr() {
    return [
      AppCard(
        radius: 28,
        padding: const EdgeInsets.all(24),
        borderColor: AppColors.slate100,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.sky100,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Container(
                      color: Colors.white,
                      child: Image.asset(
                        Mascots.bearSitting,
                        semanticLabel: 'Profile Mascot',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.emerald400,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppText('Тэмүүлэн (Таны QR)', size: 20, weight: FontWeight.w700),
            const SizedBox(height: 2),
            AppText(
              'Данс: 5041092831',
              size: 13,
              color: AppColors.dsOnSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Container(
              width: 220,
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.slate100),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned.fill(
                    child: CustomPaint(
                      painter: _FakeQrPainter(seed: 5041092831),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.sky500,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Icon(
                      Icons.wallet_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // The two labels are wider than a narrow phone at their natural
            // size, so they share the row and ellipsize instead of overflowing.
            Row(
              children: [
                Expanded(
                  child: SoftButton(
                    label: 'QR Хуваалцах',
                    icon: Icons.share_rounded,
                    height: 40,
                    background: AppColors.dsSurfaceContainerHigh,
                    foreground: AppColors.dsOnSurface,
                    border: null,
                    onPressed: () => showAppSnack(context, 'QR хуваалцах'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SoftButton(
                    label: 'Зураг хадгалах',
                    icon: Icons.download_rounded,
                    height: 40,
                    background: AppColors.dsSurfaceContainerHigh,
                    foreground: AppColors.dsOnSurface,
                    border: null,
                    onPressed: () =>
                        showAppSnack(context, 'Зураг хадгалагдлаа'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }
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

/// Decorative QR-like pattern (not a scannable code).
class _FakeQrPainter extends CustomPainter {
  const _FakeQrPainter({required this.seed});

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
  bool shouldRepaint(_FakeQrPainter old) => old.seed != seed;
}
