import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import 'camera_backdrop.dart';

/// Shown in place of the preview when the camera can't start.
class CameraError extends StatelessWidget {
  const CameraError({super.key, required this.error, required this.onRetry});

  final MobileScannerException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final (icon, title, body) = switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied => (
        Iconsax.camera_slash_copy,
        'Камерын зөвшөөрөл хэрэгтэй',
        'Тохиргоо руу орж камер ашиглахыг зөвшөөрнө үү.',
      ),
      MobileScannerErrorCode.unsupported => (
        Iconsax.video_remove_copy,
        'Камер дэмжигдэхгүй байна',
        'Энэ төхөөрөмж дээр QR уншигч ажиллахгүй байна.',
      ),
      _ => (
        Iconsax.danger_copy,
        'Камер нээж чадсангүй',
        'Түр хүлээгээд дахин оролдоно уу.',
      ),
    };
    return CameraBackdrop(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.sky500),
            const SizedBox(height: 12),
            AppText(
              title,
              size: 15,
              weight: FontWeight.w700,
              color: AppColors.slate900,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            AppText(
              body,
              size: 12,
              color: AppColors.slate500,
              textAlign: TextAlign.center,
              height: 1.4,
            ),
            if (error.errorCode != MobileScannerErrorCode.unsupported) ...[
              const SizedBox(height: 16),
              SoftButton(
                label: 'Дахин оролдох',
                icon: Iconsax.refresh_copy,
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
