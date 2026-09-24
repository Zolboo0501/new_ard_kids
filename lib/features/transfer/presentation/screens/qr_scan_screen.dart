import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/avatar.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/camera_backdrop.dart';
import '../widgets/camera_error.dart';
import '../widgets/fake_qr_painter.dart';
import '../widgets/qr_scan_viewfinder.dart';
import '../widgets/scan_result_sheet.dart';

/// "QR уншуулах": a live camera QR scanner (mobile_scanner) plus the
/// "Миний QR" tab.
///
/// The camera runs only while the scan tab is showing: [MobileScanner] starts
/// it when mounted and stops it when the tab switches away, and it pauses and
/// resumes with the app lifecycle on its own. Only codes inside the on-screen
/// frame are read ([QrScanViewfinder.frame]).
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
      builder: (_) => ScanResultSheet(value: value),
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
                      width: QrScanViewfinder.frame,
                      height: QrScanViewfinder.frame,
                    ),
                    onDetect: _onDetect,
                    placeholderBuilder: (_) => const CameraBackdrop(),
                    errorBuilder: (_, error) => CameraError(
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
                  child: QrScanViewfinder(scan: _scan),
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
                      painter: FakeQrPainter(seed: 5041092831),
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
