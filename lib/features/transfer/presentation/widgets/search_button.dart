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
    return Semantics(
      button: true,
      label: 'Данс хайх',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: loading || onTap == null ? null : withHaptic(onTap!),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: onTap == null ? AppColors.slate300 : AppColors.sky500,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.search_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              AppText(
                'Хайх',
                size: 12,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
