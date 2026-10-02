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
import '../widgets/biometric_benefit_row.dart';

/// "Биометрээр нэвтрэх" (the last registration step): offers Face ID or
/// fingerprint sign-in. Confirming scans once and turns it on (the same
/// switch as Profile › Аюулгүй байдал); either way registration ends here
/// and the teen lands on Home.
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

  void _next() => context.go(AppRoutes.home);

  Future<void> _enable() async {
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: EntranceItem.list([
                    const Header(step: 'Алхам 5/5'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.sky50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: LineIcon(
                            glyph,
                            size: 30,
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
                    const SizedBox(height: 20),
                    AppText(
                      '${kind?.loginLabel ?? 'Биометрээр нэвтрэх'} үү?',
                      size: 28,
                      weight: FontWeight.w700,
                      color: AppColors.slate900,
                      height: 1.2,
                      letterSpacing: -0.6,
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      'Дараагийн удаа нэр, код бичихгүйгээр апп руугаа орно.',
                      size: 15,
                      color: AppColors.slate500,
                      height: 1.45,
                    ),
                    const SizedBox(height: 24),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: const Column(
                        children: [
                          BiometricBenefitRow(
                            glyph: LineGlyph.bolt,
                            title: 'Хурдан нэвтэрнэ',
                            subtitle: 'Нууц үг, код бичих шаардлагагүй',
                          ),
                          SizedBox(height: 16),
                          BiometricBenefitRow(
                            glyph: LineGlyph.lock,
                            title: 'Зөвхөн чи нэвтэрнэ',
                            subtitle:
                                'Царай, хурууны хээ чинь зөвхөн утсандаа хадгалагдана',
                          ),
                          SizedBox(height: 16),
                          BiometricBenefitRow(
                            glyph: LineGlyph.settings,
                            title: 'Хүссэн үедээ унтраана',
                            subtitle: 'Профайл › Аюулгүй байдал хэсгээс',
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            AdaptiveCenter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Column(
                  children: [
                    PrimaryButton(
                      label: enabled ? 'Үргэлжлүүлэх' : '$name идэвхжүүлэх',
                      height: 56,
                      onPressed: _busy ? null : _enable,
                    ),
                    if (!enabled) ...[
                      const SizedBox(height: 4),
                      TextButton(
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
                    ],
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
