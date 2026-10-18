import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/biometrics.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../../auth/presentation/widgets/header.dart';
import '../../../auth/presentation/widgets/submit_button.dart';

/// "Биометрээр нэвтрэх": offers Face ID or fingerprint sign-in. Confirming
/// scans once and turns it on (the same switch as Profile › Аюулгүй байдал);
/// either way the flow goes on to the parent link.
class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  /// The enrolled biometric, or null while checking or when nothing is
  /// enrolled yet (the scan then explains how to enrol).
  BiometricKind? _kind;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    Biometrics.instance.available().then((kind) {
      if (mounted) setState(() => _kind = kind);
    });
  }

  void _next() => context.push(AppRoutes.parentLinkOnboarding);

  Future<void> _enable() async {
    if (_busy) return;
    if (appBiometricLogin.value) return _next();
    setState(() => _busy = true);
    final result = await Biometrics.instance.authenticate(
      'Биометрээр нэвтрэхийг идэвхжүүлэх',
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (result != BiometricResult.success) {
      if (result.message case final message?) showAppSnack(context, message);
      // A face or finger may have been enrolled since the screen opened.
      if (result == BiometricResult.notEnrolled) {
        final kind = await Biometrics.instance.available();
        if (mounted) setState(() => _kind = kind);
      }
      return;
    }
    await BiometricStore.save(true);
    if (!mounted) return;
    showAppSnack(
      context,
      '${(_kind ?? BiometricKind.fingerprint).name} идэвхжлээ',
    );
    _next();
  }

  @override
  Widget build(BuildContext context) {
    final kind = _kind;
    final enabled = appBiometricLogin.value;
    final name = kind?.name ?? 'Биометр';
    final glyph = kind == BiometricKind.face
        ? LineGlyph.faceId
        : LineGlyph.fingerprint;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: EntranceScope(
                child: AdaptiveListView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  children: EntranceItem.list([
                    const Header(step: 'Алхам 5/6'),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.sky50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: LineIcon(
                            glyph,
                            size: 32,
                            color: AppColors.sky600,
                          ),
                        ),
                        const Spacer(),
                        if (enabled)
                          StatusBadge(
                            label: 'Идэвхтэй',
                            tone: BadgeTone.emerald,
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppText(
                      '${kind?.loginLabel ?? 'Биометрээр нэвтрэх'} үү?',
                      size: 30,
                      weight: FontWeight.w700,
                      color: AppColors.slate900,
                      height: 1.15,
                      letterSpacing: -0.6,
                    ),
                    const SizedBox(height: 10),
                    AppText(
                      'Дараагийн удаа нэр, код бичихгүйгээр апп руугаа орно. '
                      'Хүссэн үедээ Профайл › Аюулгүй байдал хэсгээс унтраана.',
                      size: 15,
                      color: AppColors.slate500,
                      height: 1.45,
                    ),
                  ]),
                ),
              ),
            ),
            AdaptiveCenter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                child: Column(
                  children: [
                    SubmitButton(
                      label: enabled ? 'Үргэлжлүүлэх' : '$name идэвхжүүлэх',
                      onPressed: _enable,
                    ),
                    // Always the same height, so the button doesn't move
                    // once it is turned on.
                    SizedBox(
                      height: 52,
                      child: enabled
                          ? null
                          : TextButton(
                              onPressed: _busy ? null : _next,
                              style: TextButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: AppText(
                                'Дараа болъё',
                                size: 15,
                                weight: FontWeight.w600,
                                color: AppColors.slate600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
