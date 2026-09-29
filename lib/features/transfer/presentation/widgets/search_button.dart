import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

/// The Хайх pill at the end of the account number field.
class SearchButton extends StatelessWidget {
  const SearchButton({super.key, required this.onTap, this.loading = false});

  final bool loading;

  /// Null while the search can't run yet (too few digits).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // A disabled pill is a raised surface with muted ink; enabled, it is the
    // accent fill with its own ink.
    final ink = onTap == null ? AppColors.slate400 : AppColors.onAccent;
    return Semantics(
      button: true,
      label: 'Данс хайх',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: loading || onTap == null ? null : withHaptic(onTap!),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: onTap == null ? AppColors.slate100 : AppColors.sky500,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: ink),
                )
              else
                LineIcon(LineGlyph.search, size: 16, color: ink),
              const SizedBox(width: 4),
              AppText('Хайх', size: 13, weight: FontWeight.w600, color: ink),
            ],
          ),
        ),
      ),
    );
  }
}
