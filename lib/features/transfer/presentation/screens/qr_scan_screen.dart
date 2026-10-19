import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../app/accounts.dart';
import '../../../../app/avatar.dart';
import '../../../../app/kid_profile.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/camera_backdrop.dart';
import '../widgets/camera_error.dart';
import '../widgets/fake_qr_painter.dart';
import '../widgets/qr_scan_viewfinder.dart';
import '../widgets/scan_result_sheet.dart';
import '../../../../widgets/avatar_tour.dart';

/// "QR уншуулах": a live camera QR scanner (mobile_scanner) plus the
/// "Миний QR" tab. It is the middle tab of the signed-in shell, so the
/// floating bar stays under it and there is no back button.
///
/// The screen owns the camera (`autoStart: false`): it starts it once the
/// scanner is on screen, stops it when the tab switches to "Миний QR" and
/// starts it again on the way back, stops it while another shell tab is
/// showing (the shell turns [TickerMode] off for hidden tabs), and follows
/// the app lifecycle (stopped
/// while the app is not in the foreground, which includes the iOS permission
/// prompt). The [MobileScanner] widget can't do this itself here: the tab
/// view keeps the outgoing pane mounted while the incoming one appears, so
/// its own start-on-mount ran before the old pane's stop-on-dispose and the
/// preview came back dead. Only codes inside the on-screen frame are read
/// ([QrScanViewfinder.frameFor]).
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        AvatarTourHost {
  /// What the first-visit tour points at.
  final _tabsKey = GlobalKey();
  final _cameraKey = GlobalKey();

  late final _scan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  final _camera = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  int _tab = 0;

  /// Where the tabs' pill sits while the content is swiped, in tabs; null
  /// otherwise.
  double? _tabDrag;

  /// Whether this shell tab is the one on screen ([TickerMode] is off for
  /// the hidden ones).
  bool _active = true;

  /// Set while a scanned code is being shown, so further frames that still
  /// see the code don't open a second sheet.
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    // The first visit: the avatar walks the teen through this screen.
    startAvatarTour('qr_scan', () {
      final name = appAvatar.value.name;
      return [
        AvatarTourStep(text: 'Би $name. QR кодоор хурдан төлөхийг хамт үзье!'),
        AvatarTourStep(
          target: _tabsKey,
          text:
              'QR унших — дэлгүүрийн кодыг уншуулна. Миний QR — өөрийн кодоо бусдад харуулна.',
        ),
        AvatarTourStep(
          target: _cameraKey,
          text: 'Кодыг хүрээн дотор байлгахад автоматаар уншина.',
        ),
      ];
    });
    WidgetsBinding.instance.addObserver(this);
    // After the first frame, so the scanner widget is attached.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCamera());
  }

  /// Starts the camera unless it is already running or starting (a second
  /// start() while one is in progress throws). Errors surface through the
  /// scanner's own error state, so the screen shows [CameraError].
  Future<void> _startCamera() async {
    if (!mounted || !_active || _tab != 0 || _handling) return;
    final state = _camera.value;
    if (state.isRunning || state.isStarting) return;
    try {
      await _camera.start();
    } on MobileScannerException catch (e) {
      debugPrint('QR camera start failed: ${e.errorCode} ${e.errorDetails}');
    }
  }

  Future<void> _stopCamera() async {
    if (!_camera.value.isInitialized) return;
    try {
      await _camera.stop();
    } on MobileScannerException catch (e) {
      debugPrint('QR camera stop failed: ${e.errorCode}');
    }
  }

  /// "Дахин оролдох": a clean stop before the start, so a controller left
  /// in a failed state can start again.
  Future<void> _retryCamera() async {
    await _stopCamera();
    await _startCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active = TickerMode.valuesOf(context).enabled;
    if (active == _active) return;
    _active = active;
    if (active) {
      unawaited(_startCamera());
    } else {
      unawaited(_stopCamera());
    }
  }

  void _setTab(int i) {
    if (i == _tab) return;
    setState(() => _tab = i);
    if (i == 0) {
      // The scan pane is mounted on the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => _startCamera());
    } else {
      unawaited(_stopCamera());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scan.dispose();
    unawaited(_camera.dispose());
    super.dispose();
  }

  /// The pattern mobile_scanner documents: stop while the app is not in the
  /// foreground, start again when it is. Before permission is granted the
  /// controller is left alone, so the first start (which asks for it) isn't
  /// interrupted.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_camera.value.hasCameraPermission) return;
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_startCamera());
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        unawaited(_stopCamera());
      case AppLifecycleState.detached:
        break;
    }
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
      await context.push(AppRoutes.transferAmount);
      if (!mounted) return;
    }
    _handling = false;
    unawaited(_startCamera());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dsSurface,
      appBar: SubPageHeader(
        title: 'QR уншуулах',
        showBack: false,
        background: AppColors.dsSurface,
        trailing: _tab == 0
            ? ValueListenableBuilder(
                valueListenable: _camera,
                builder: (context, state, _) {
                  final on = state.torchState == TorchState.on;
                  return CircleIconButton(
                    icon: on ? Iconsax.flash_copy : Iconsax.flash_slash_copy,
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
      // Not a list: the scan tab's camera takes all the height between the
      // tabs and the bar, and the "Миний QR" tab scrolls on its own.
      body: EntranceScope(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16 + MediaQuery.paddingOf(context).left,
            12,
            16 + MediaQuery.paddingOf(context).right,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EntranceItem(
                index: 0,
                child: KeyedSubtree(
                  key: _tabsKey,
                  child: AppTabs(
                    tabs: const [
                      AppTab('QR унших', icon: Iconsax.scan_barcode_copy),
                      AppTab('Миний QR', icon: Iconsax.scanner_copy),
                    ],
                    index: _tab,
                    style: AppTabsStyle.solid,
                    dragPosition: _tabDrag,
                    onChanged: _setTab,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: EntranceItem(
                  index: 1,
                  // Swiping the content moves between the two tabs; past
                  // them it goes on to the bar's neighbours, Нүүр and
                  // Чат.
                  child: AppTabSwipe(
                    index: _tab,
                    count: 2,
                    onChanged: _setTab,
                    onDrag: (p) => setState(() => _tabDrag = p),
                    onPastStart: () =>
                        StatefulNavigationShell.of(context).goBranch(0),
                    onPastEnd: () =>
                        StatefulNavigationShell.of(context).goBranch(2),
                    // Each pane gets the full height itself: the tab view
                    // lays a leaving pane out unbounded.
                    child: LayoutBuilder(
                      builder: (context, constraints) => AppTabView(
                        index: _tab,
                        child: SizedBox(
                          height: constraints.maxHeight,
                          child: _tab == 0 ? _buildScan() : _buildMyQr(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The camera fills what the tabs, the note and the bar leave, and
        // runs edge to edge past the page's side padding; the frame inside
        // takes 85% of its shorter side.
        Expanded(
          child: KeyedSubtree(
            key: _cameraKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth + _bleed * 2;
                return OverflowBox(
                  minWidth: width,
                  maxWidth: width,
                  child: _cameraView(),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        InfoNote(
          icon: Iconsax.shield_tick_copy,
          text:
              'Өдрийн шилжүүлгийн эрх ${formatMnt(Limits.dailyTransfer)}. '
              'Өнөөдөр ${formatMnt(Limits.leftToday)} үлдсэн.',
        ),
        SizedBox(height: AppLayout.navClearance(context)),
      ],
    );
  }

  /// How far the camera reaches past the page's side padding: all of it.
  static const _bleed = 16.0;

  Widget _cameraView() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Only the scanner needs the size: its scan window is the centred
        // frame, in its own coordinates.
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final frame = QrScanViewfinder.frameFor(constraints.biggest);
              return MobileScanner(
                controller: _camera,
                scanWindow: Rect.fromCenter(
                  center: constraints.biggest.center(Offset.zero),
                  width: frame,
                  height: frame,
                ),
                onDetect: _onDetect,
                placeholderBuilder: (_) => const CameraBackdrop(),
                errorBuilder: (_, error) {
                  debugPrint('QR camera: ${error.errorCode} $error');
                  return CameraError(
                    error: error,
                    onRetry: () => unawaited(_retryCamera()),
                  );
                },
              );
            },
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
    );
  }

  Widget _buildMyQr() {
    return ListView(
      // The page's side padding is already applied; only clear the bar.
      padding: EdgeInsets.only(bottom: AppLayout.navClearance(context)),
      children: [
        AppCard(
          padding: const EdgeInsets.all(24),
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
                        color: AppColors.sky50,
                        // The kid's chosen companion, as on Home and Profile.
                        child: Image.asset(
                          appAvatar.value.portrait,
                          fit: BoxFit.cover,
                          semanticLabel: Kid.shortName,
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
                        border: Border.all(color: AppColors.card, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: LineIcon(
                        LineGlyph.check,
                        size: 12,
                        stroke: 2.5,
                        color: AppColors.onBright,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppText(Kid.shortName, size: 20, weight: FontWeight.w700),
              const SizedBox(height: 2),
              AppText(
                formatIban(Accounts.main),
                size: 13,
                color: AppColors.dsOnSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Container(
                width: 220,
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // The code keeps its own white quiet zone so it scans.
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned.fill(
                      child: CustomPaint(
                        painter: FakeQrPainter(seed: 5049821900),
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
                      child: Icon(
                        Iconsax.wallet_2_copy,
                        size: 22,
                        color: AppColors.onAccent,
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
                      leadingIcon: Iconsax.share_copy,
                      height: 48,
                      onPressed: () => showAppSnack(context, 'QR хуваалцах'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SoftButton(
                      label: 'Зураг хадгалах',
                      icon: Iconsax.document_download_copy,
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
      ],
    );
  }
}
