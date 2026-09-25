import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class LimitCard extends StatelessWidget {
  const LimitCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.muted,
    required this.stats,
    required this.footer,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget badge;
  final bool muted;

  /// `(label, value, tone)`; see [_StatBox.value].
  final List<(String, Object, BadgeTone?)> stats;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: muted ? AppColors.slate100.withValues(alpha: 0.8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: muted
              ? AppColors.slate200.withValues(alpha: 0.7)
              : AppColors.emerald200.withValues(alpha: 0.8),
        ),
        boxShadow: muted
            ? null
            : [
                BoxShadow(
                  color: AppColors.emerald500.withValues(alpha: 0.18),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                  spreadRadius: -8,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: muted ? AppColors.slate200 : AppColors.emerald100,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: muted ? AppColors.slate500 : AppColors.emerald600,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(title, size: 13, weight: FontWeight.w700),
                    AppText(
                      subtitle,
                      size: 11,
                      weight: muted ? FontWeight.w500 : FontWeight.w700,
                      color: muted ? AppColors.slate500 : AppColors.emerald600,
                    ),
                  ],
                ),
              ),
              badge,
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final (i, s) in stats.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _StatBox(label: s.$1, value: s.$2, tone: s.$3),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          footer,
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, this.tone});

  final String label;

  /// An amount, an `(amount, suffix)` pair such as `(100000, '+')`, or text.
  final Object value;
  final BadgeTone? tone;

  @override
  Widget build(BuildContext context) {
    final colors = tone?.colors;
    final color = colors?.$2 ?? AppColors.slate800;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors?.$1 ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors?.$3 ?? AppColors.slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            size: 11,
            weight: FontWeight.w500,
            color: colors?.$2 ?? AppColors.slate500,
          ),
          const SizedBox(height: 2),
          // Shrinks rather than overflowing in the half-width box.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: switch (value) {
              final num amount => _amount(amount, color),
              (final num amount, final String suffix) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _amount(amount, color),
                  Text(suffix, style: _textStyle(color)),
                ],
              ),
              _ => Text('$value', style: _textStyle(color)),
            },
          ),
        ],
      ),
    );
  }

  static Widget _amount(num amount, Color color) => BalanceText(
    amount,
    space: false,
    size: 14,
    weight: FontWeight.w500,
    color: color,
    decimals: false,
  );

  static TextStyle _textStyle(Color color) =>
      moneyStyle(size: 14, weight: FontWeight.w500, color: color);
}
