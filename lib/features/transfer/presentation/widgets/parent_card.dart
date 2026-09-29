import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import 'transfer_initials.dart';

/// A parent the request can go to: initials, name and masked account,
/// outlined in the accent while picked.
class ParentCard extends StatelessWidget {
  const ParentCard({
    super.key,
    required this.name,
    required this.initials,
    required this.account,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String initials;
  final String account;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$name, $account',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              TransferInitials(initials, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      name,
                      size: 14,
                      weight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      account,
                      size: 12,
                      color: AppColors.slate500,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
