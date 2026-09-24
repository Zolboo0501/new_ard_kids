/// Notes, progress and snack bars that tell the kid what happened.
library;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../app_text.dart';
import 'chips.dart';
import 'mascots.dart';

/// Soft informational note with a leading icon.
class InfoNote extends StatelessWidget {
  const InfoNote({
    super.key,
    required this.text,
    this.icon = Icons.info_outline_rounded,
    this.tone = BadgeTone.sky,
    this.title,
    this.mascot,
  });

  final String text;
  final String? title;
  final IconData icon;
  final BadgeTone tone;

  /// A [Mascots] asset shown instead of [icon].
  final String? mascot;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = tone.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mascot != null)
            MascotIcon(mascot!, size: 24)
          else
            Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: AppText(
                      title!,
                      size: 12,
                      weight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                AppText(
                  text,
                  size: 11,
                  weight: FontWeight.w500,
                  color: AppColors.slate600,
                  height: 1.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded progress track with a colored fill.
class ProgressTrack extends StatelessWidget {
  const ProgressTrack({
    super.key,
    required this.value,
    this.height = 8,
    this.color,
    this.track = AppColors.slate100,
  });

  final double value;
  final double height;

  /// Defaults to the theme accent (`AppColors.sky500`).
  final Color? color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: track)),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color ?? AppColors.sky500,
                  borderRadius: BorderRadius.circular(height),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a short confirmation snack bar in the app style.
///
/// [mascot] (a [Mascots] asset) shows an animal before the message, e.g. a
/// celebrating bear for a success.
void showAppSnack(BuildContext context, String message, {String? mascot}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.slate800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: mascot == null
            ? AppText(message, size: 13, color: Colors.white)
            : Row(
                children: [
                  MascotIcon(mascot, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppText(message, size: 13, color: Colors.white),
                  ),
                ],
              ),
      ),
    );
}
