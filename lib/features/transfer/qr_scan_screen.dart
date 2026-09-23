import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/avatar.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_tabs.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';
import '../../widgets/entrance.dart';

/// "QR уншуулах": a live camera QR scanner (mobile_scanner) plus the
/// "Миний QR" tab.
///
/// The camera runs only while the scan tab is showing: [MobileScanner] starts
/// it when mounted and stops it when the tab switches away, and it pauses and
/// resumes with the app lifecycle on its own. Only codes inside the on-screen
/// frame are read ([_frame]).
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

  final _camera = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  /// Side of the square viewfinder; also the scan window.
  static const _frame = 224.0;

  int _tab = 0;

  /// Set while a scanned code is being shown, so further frames that still
  /// see the code don't open a second sheet.
  bool _handling = false;

  @override
  void dispose() {
    _scan.dispose();
    unawaited(_camera.dispose());
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    final value = capture.barcodes
        .map((b) => b.rawValue)
        .nonNulls
        .where((v) => v.isNotEmpty)
        .firstOrNull;
    if (value == null) return;
    _handling = true;
    unawaited(HapticFeedback.mediumImpact());
    // Freeze the preview on the code while the result is shown.
    await _camera.pause();
    if (!mounted) return;

    final transfer = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScanResultSheet(value: value),
    );
    if (!mounted) return;
    if (transfer ?? false) {
      // TODO: parse the recipient from [value] and prefill the transfer.
      await context.push(AppRoutes.transfer);
      if (!mounted) return;
    }
    _handling = false;
    if (_tab == 0) unawaited(_camera.start());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dsSurface,
      appBar: SubPageHeader(
        title: 'QR уншуулах',
        background: AppColors.dsSurface,
        trailing: _tab == 0
            ? ValueListenableBuilder(
                valueListenable: _camera,
                builder: (context, state, _) {
                  final on = state.torchState == TorchState.on;
                  return CircleIconButton(
                    icon: on
                        ? Icons.flashlight_on_rounded
                        : Icons.highlight_rounded,
                    label: 'Гэрэл асаах/унтраах',
                    color: on ? AppColors.amber500 : AppColors.slate600,
                    // No flash (or no camera yet): the button does nothing.
                    onPressed:
                        state.isRunning &&
                            state.torchState != TorchState.unavailable
                        ? () => unawaited(_camera.toggleTorch())
                        : null,
                  );
                },
              )
            : null,
      ),
      body: EntranceScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
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
          ]),
        ),
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
              // Only the scanner needs the size: its scan window is the
              // centred frame, in its own coordinates.
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) => MobileScanner(
                    controller: _camera,
                    scanWindow: Rect.fromCenter(
                      center: constraints.biggest.center(Offset.zero),
                      width: _frame,
                      height: _frame,
                    ),
                    onDetect: _onDetect,
                    placeholderBuilder: (_) => const _CameraBackdrop(),
                    errorBuilder: (_, error) => _CameraError(
                      error: error,
                      onRetry: () => unawaited(_camera.start()),
                    ),
                  ),
                ),
              ),
              // The viewfinder only makes sense over a working camera.
              Positioned.fill(
                child: ValueListenableBuilder(
                  valueListenable: _camera,
                  builder: (context, state, child) =>
                      state.error == null ? child! : const SizedBox.shrink(),
                  child: _Viewfinder(scan: _scan),
                ),
              ),
            ],
          ),
        ),
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
                  decoration: BoxDecoration(
                    color: AppColors.sky100,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Container(
                      color: Colors.white,
                      // The kid's chosen companion, as on Home and Profile.
                      child: Image.asset(
                        appAvatar.value.portrait,
                        fit: BoxFit.cover,
                        semanticLabel: 'Тэмүүлэн',
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
            // Sharing is the tab's main action, so it leads in the accent;
            // saving sits beside it as the softer secondary. The labels are
            // wider than a narrow phone at their natural size, so they share
            // the row and ellipsize instead of overflowing.
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'QR Хуваалцах',
                    leadingIcon: Icons.share_rounded,
                    height: 48,
                    onPressed: () => showAppSnack(context, 'QR хуваалцах'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SoftButton(
                    label: 'Зураг хадгалах',
                    icon: Icons.download_rounded,
                    height: 48,
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

/// Dark fill shown until the camera's first frame (and behind errors).
class _CameraBackdrop extends StatelessWidget {
  const _CameraBackdrop({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF101B2B), Color(0xFF1A2838), Color(0xFF0F1A28)],
        ),
      ),
      child: SizedBox.expand(child: child),
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

/// The whole area minus a centred [_QrScanScreenState._frame] square with
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
          width: _QrScanScreenState._frame,
          height: _QrScanScreenState._frame,
        ),
        _radius,
      ),
    );

  @override
  bool shouldReclip(_HoleClipper old) => false;
}

/// Everything drawn over the camera: the blur around the frame, the frame
/// corners, a sweeping scan line and the hint. Fills the whole camera view.
class _Viewfinder extends StatelessWidget {
  const _Viewfinder({required this.scan});

  final Animation<double> scan;

  static const _frame = _QrScanScreenState._frame;
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
            width: _frame,
            height: _frame,
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
                        (_frame - 2 * _inset) *
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

/// Shown in place of the preview when the camera can't start.
class _CameraError extends StatelessWidget {
  const _CameraError({required this.error, required this.onRetry});

  final MobileScannerException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final (icon, title, body) = switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied => (
        Icons.no_photography_outlined,
        'Камерын зөвшөөрөл хэрэгтэй',
        'Тохиргоо руу орж камер ашиглахыг зөвшөөрнө үү.',
      ),
      MobileScannerErrorCode.unsupported => (
        Icons.videocam_off_outlined,
        'Камер дэмжигдэхгүй байна',
        'Энэ төхөөрөмж дээр QR уншигч ажиллахгүй байна.',
      ),
      _ => (
        Icons.error_outline_rounded,
        'Камер нээж чадсангүй',
        'Түр хүлээгээд дахин оролдоно уу.',
      ),
    };
    return _CameraBackdrop(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.sky300),
            const SizedBox(height: 12),
            AppText(
              title,
              size: 15,
              weight: FontWeight.w700,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            AppText(
              body,
              size: 12,
              color: Colors.white.withValues(alpha: 0.75),
              textAlign: TextAlign.center,
              height: 1.4,
            ),
            if (error.errorCode != MobileScannerErrorCode.unsupported) ...[
              const SizedBox(height: 16),
              SoftButton(
                label: 'Дахин оролдох',
                icon: Icons.refresh_rounded,
                height: 40,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet with the scanned value; pops `true` to start a transfer.
class _ScanResultSheet extends StatelessWidget {
  const _ScanResultSheet({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.emerald50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: AppColors.emerald600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  'QR код уншигдлаа',
                  size: 16,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.slate100),
            ),
            child: AppText(
              value,
              size: 12,
              color: AppColors.slate600,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Гүйлгээ хийх',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => Navigator.pop(context, true),
          ),
          const SizedBox(height: 8),
          SoftButton(
            label: 'Дахин унших',
            icon: Icons.qr_code_scanner_rounded,
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
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
