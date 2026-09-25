import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/avatar.dart';
import '../../../../app/biometrics.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../../auth/presentation/widgets/header.dart';
import '../widgets/biometric_benefit_row.dart';

/// "Биометрээр нэвтрэх" (onboarding step 5/6): offers Face ID or fingerprint
/// sign-in. Confirming scans once and turns it on (the same switch as
/// Profile › Аюулгүй байдал); either way the flow goes on to the parent link.
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
      mascot: Stickers.shield,
    );
    _next();
  }

  @override
  Widget build(BuildContext context) {
    final kind = _kind;
    final enabled = appBiometricLogin.value;
    final name = kind?.name ?? 'Биометр';
    return Scaffold(
      backgroundColor: AppColors.dsSurface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: EntranceScope(
                child: AdaptiveListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: EntranceItem.list([
                    Header(
                      step: 'Алхам 5/6',
                      trailing: GestureDetector(
                        onTap: withHaptic(_next),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const AppText(
                            'Алгасах',
                            size: 11,
                            weight: FontWeight.w600,
                            color: AppColors.slate600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: MascotImage(
                        asset: Stickers.lock,
                        size: 150,
                        background: AppColors.dsSurface,
                        semanticLabel: 'Утас барьсан маскот',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: StatusBadge(
                        label: enabled
                            ? '$name идэвхтэй'
                            : 'Нэг удаагийн тохиргоо',
                        tone: enabled ? BadgeTone.emerald : BadgeTone.amber,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppText(
                      '${kind?.loginLabel ?? 'Биометрээр нэвтрэх'} үү?',
                      size: 24,
                      weight: FontWeight.w700,
                      letterSpacing: -0.5,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 290),
                        child: const AppText(
                          'Дараагийн удаа код бичихгүйгээр, утсаа нэг хараад л апп руугаа орно.',
                          size: 12,
                          color: AppColors.slate500,
                          height: 1.6,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          BiometricBenefitRow(
                            icon: kind?.icon ?? Icons.fingerprint_rounded,
                            tone: BadgeTone.sky,
                            title: 'Хормын дотор нэвтэрнэ',
                            subtitle: 'Нууц үг, код бичих шаардлагагүй',
                          ),
                          const SizedBox(height: 14),
                          const BiometricBenefitRow(
                            icon: Icons.lock_outline_rounded,
                            tone: BadgeTone.emerald,
                            title: 'Зөвхөн чи л нэвтэрнэ',
                            subtitle:
                                'Царай, хурууны хээ чинь зөвхөн утсандаа хадгалагдана',
                          ),
                          const SizedBox(height: 14),
                          const BiometricBenefitRow(
                            icon: Icons.toggle_on_outlined,
                            tone: BadgeTone.amber,
                            title: 'Хүссэн үедээ унтраана',
                            subtitle: 'Профайл › Аюулгүй байдал цэснээс',
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
                      leadingIcon: enabled
                          ? null
                          : kind?.icon ?? Icons.fingerprint_rounded,
                      height: 56,
                      onPressed: _busy ? null : _enable,
                    ),
                    if (!enabled) ...[
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: _busy ? null : _next,
                        child: AppText(
                          'Дараа болъё',
                          size: 13,
                          weight: FontWeight.w600,
                          color: AppColors.slate500,
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
