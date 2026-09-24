import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';

class ParentCard extends StatelessWidget {
  const ParentCard({
    super.key,
    required this.name,
    required this.account,
    required this.asset,
    required this.tint,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String account;
  final String asset;
  final Color tint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.slate200,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              MascotTile(asset: asset, size: 44, background: tint, radius: 12),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                            name,
                            size: 12,
                            weight: FontWeight.w700,
                            color: selected
                                ? AppColors.sky900
                                : AppColors.slate700,
                          ),
                        ),
                        if (selected)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.sky600,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      account,
                      size: 10,
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
