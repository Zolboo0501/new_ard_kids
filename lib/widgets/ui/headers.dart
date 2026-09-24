/// Page and section headers.
library;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../app_text.dart';
import '../common.dart';
import 'interaction.dart';
import 'surfaces.dart';
import 'mascots.dart';

/// Top bar for pushed screens: back button, centered title, optional action.
class SubPageHeader extends StatelessWidget implements PreferredSizeWidget {
  const SubPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onBack,
    this.background,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onBack;

  /// Defaults to [kPageBackground].
  final Color? background;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: (background ?? kPageBackground).withValues(alpha: 0.95),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.sky100.withValues(alpha: 0.6),
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: showBack
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: CircleBackButton(onPressed: onBack),
                      )
                    : null,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      title,
                      size: 16,
                      weight: FontWeight.w700,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      AppText(
                        subtitle!,
                        size: 11,
                        weight: FontWeight.w500,
                        color: AppColors.slate400,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 44,
                child: Align(alignment: Alignment.centerRight, child: trailing),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section heading with an optional trailing action link.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.icon,
    this.mascot,
    this.padding = const EdgeInsets.fromLTRB(4, 4, 4, 8),
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final IconData? icon;

  /// A [Mascots] asset shown before the title, in place of an emoji.
  final String? mascot;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.sky500),
            const SizedBox(width: 6),
          ],
          if (mascot != null) ...[
            MascotIcon(mascot!, size: 22),
            const SizedBox(width: 6),
          ],
          Expanded(child: AppText(title, size: 14, weight: FontWeight.w700)),
          if (action != null)
            GestureDetector(
              onTap: withHaptic(onAction),
              child: AppText(
                action!,
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.sky600,
              ),
            ),
        ],
      ),
    );
  }
}
